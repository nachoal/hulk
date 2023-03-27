# Hulk
Hulk is a powerful, self-healing Ruby script runner with a "strong" ability to automatically fix buggy code. Inspired by its namesake, the Incredible Hulk, this tool smashes bugs with incredible strength and regenerates its code to keep running. Hulk is powered by GPT-4, a cutting-edge AI language model, to diagnose and repair code issues in real-time.

## Requirements
* Ruby 3.2.0

## Dependencies
* openai
* json
* fileutils
* open3
* colored
* diffy
* thor

## Installation
1. Clone the repository:
`git clone https://github.com/yourusername/hulk.git`
2. Navigate to the project directory:
`cd hulk`

3. Install the required gems
`gem install ruby-openai dotenv json fileutils open3 colored diffy thor`

4. Set up your OpenAI API key:
Create a file called openai_key.txt in the project directory, and paste your OpenAI API key into it.

## Usage

To use Hulk, simply run it with the name of the script you'd like to execute, followed by any required arguments. Hulk will attempt to run the script, and if it encounters any errors, it will automatically diagnose and fix them using GPT-4. Hulk will then rerun the script, repeating this process until the script runs successfully or the user manually stops it.

```bash
ruby hulk.rb <script_name> <arg1> <arg2> ...
```


## Example

```bash
ruby hulk.rb buggy_code.rb add 4 2
```


To revert any changes Hulk made to a script, simply add the `--revert` flag at the end of the command:

```bash
ruby hulk.rb buggy_code.rb --revert
```

## Limitations
Hulk's self-healing capabilities are impressive, but they're not infallible. In some cases, Hulk may be unable to fix a particular issue or may introduce new issues in the process. Additionally, Hulk may not be able to handle complex or highly specialized codebases with the same level of accuracy as simpler scripts.

## Contributing
We welcome contributions to Hulk! If you'd like to contribute, please submit a pull request or open an issue to discuss your ideas.

## License
This project is licensed under the MIT License. See the LICENSE file for more information.