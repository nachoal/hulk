require 'thor'

class Calculator < Thor
  def self.exit_on_failure?
    true
  end

  desc 'add NUM1 NUM2', 'Add two numbers'
  def add(num1, num2)
    puts num1 + num2.to_i
  end

  desc 'substract NUM1 NUM2', 'Subtracts two numbers'
  def substract(num1, num2)
    puts num1.to_i - num2.to_i
  end

  desc 'multiply NUM1 NUM2', 'Multiply two numbers'
  def multiply(num1, num2)
  end

  desc 'divide NUM1 NUM2', 'Divide two numbers'
  def divide(num1, num2)
    num2.to_i.zero? ? (puts 'Error: Division by zero.') : (puts num1.to_i / num2.to_i)
  end
end

Calculator.start(ARGV)
