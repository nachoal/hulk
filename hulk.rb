# frozen_string_literal: true

require 'openai'
require 'dotenv/load'
require 'json'
require 'fileutils'
require 'open3'
require 'colored'
require 'diffy'

OpenAI.configure do |config|
  config.access_token = File.read('openai_key.txt').strip
end

def run_script(script_name, *args)
  cmd = "#{RbConfig.ruby} #{script_name} #{args.join(' ')}"
  output, status = Open3.capture2e(cmd)

  [output, status.exitstatus]
end

def send_error_to_gpt4(client, file_path, args, error_message)
  file_lines = File.readlines(file_path)
  file_with_lines = file_lines.each_with_index.map { |line, idx| "#{idx + 1}: #{line}" }.join

  initial_prompt_text = File.read('prompt.txt')

  prompt = build_prompt(initial_prompt_text, args, error_message, file_with_lines)

  response = client.chat(
    parameters: { model: 'gpt-4', messages: [{ role: 'user', content: prompt }], temperature: 1.0 }
  )

  response.dig('choices', 0, 'message', 'content').strip
end

def build_prompt(initial_prompt_text, args, error_message, file_with_lines)
  initial_prompt_text +
    "\n\n" \
    "Here is the script that needs fixing:\n\n" \
    "#{file_with_lines}\n\n" \
    "Here are the arguments it was provided:\n\n" \
    "#{args}\n\n" \
    "Here is the error message:\n\n" \
    "#{error_message}\n" \
    'Please provide your suggested changes, and remember to stick to the ' \
    'exact format as described above.'
end

def apply_changes(file_path, changes_json)
  original_file_lines = File.readlines(file_path)
  changes = JSON.parse(changes_json)

  operation_changes = changes.select { |change| change.key?('operation') }
  explanations = changes.select { |change| change.key?('explanation') }.map { |change| change['explanation'] }

  operation_changes.sort_by! { |x| -x['line'] }
  file_lines = original_file_lines.dup

  operation_changes.each do |change|
    operation = change['operation']
    line = change['line']
    content = change['content']

    case operation
    when 'Replace'
      leading_whitespace = original_file_lines[line - 1][/\A\s*/]
      file_lines[line - 1] = "#{leading_whitespace}#{content}\n"
    when 'Delete'
      file_lines.delete_at(line - 1)
    when 'InsertAfter'
      leading_whitespace = original_file_lines[line - 1][/\A\s*/]
      file_lines.insert(line, "#{leading_whitespace}#{content}\n")
    end
  end

  File.write(file_path, file_lines.join)

  puts 'Explanations:'.blue
  explanations.each { |explanation| puts "- #{explanation}".blue }

  puts "\nChanges:"
  diff = Diffy::Diff.new(original_file_lines.join, file_lines.join, context: 2)
  puts diff.to_s(:color)
end

def main
  if ARGV.length < 2
    puts 'Usage: wolverine.rb <script_name> <arg1> <arg2> ... [--revert]'
    exit(1)
  end

  script_name = ARGV[0]
  args = ARGV[1..]
  client = OpenAI::Client.new

  if args.include?('--revert')
    backup_file = "#{script_name}.bak"
    if File.exist?(backup_file)
      FileUtils.cp(backup_file, script_name)
      puts "Reverted changes to #{script_name}"
      exit(0)
    else
      puts "No backup file found for #{script_name}"
      exit(1)
    end
  end

  FileUtils.cp(script_name, "#{script_name}.bak")

  loop do
    output, returncode = run_script(script_name, *args)

    if returncode.zero?
      puts 'Script ran successfully.'.blue
      puts "Output: #{output}"
      break
    else
      puts 'Script crashed. Trying to fix...'.blue
      puts "Output: #{output}"

      json_response = send_error_to_gpt4(client, script_name, args, output)
      apply_changes(script_name, json_response)
      puts 'Changes applied. Rerunning...'.blue
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
