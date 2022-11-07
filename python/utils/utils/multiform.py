
"""

Command builder for multi-stack Terraform.

This script has the following dependencies:

* Python 3.8 or above
* Terraform 1 or above

It is provided under the terms of the MIT License:

MIT License

Copyright (c) 2022 Stuart Ellis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

"""

import argparse

"""Semantic version of script"""
VERSION = "0.1.0"

"""Version of Terraform Stacks Specification"""
TF_STACKS_SPEC_VERSION = "0.1.0"

"""Default settings"""
DEFAULTS = {
    'terraform_root_dir': 'terraform',
    'terraform_stacks_dir': 'stacks',
}

"""Templates for Terraform subcommands"""
CMD_TEMPLATES = {
    'fmt': '',
    'init': '',
    'plan': '',
    'validate': '',
}


def build_arg_parser(subcommands, version):
    """Creates the parser for the command-line arguments"""
    parser = argparse.ArgumentParser(
        description='Command builder for multi-stack Terraform.')
    parser.add_argument(
        '-v', '--version',
        help='show the version of this script and exit',
        action='version', version="%(prog)s " + version)
    return parser


def build_config(arguments, defaults):
    """Creates a configuration"""
    config = {}


def main(builder_config, defaults, commands, version):
    """Main function for running script from the command-line"""
    parser = build_arg_parser(set(commands), version)
    arguments = vars(parser.parse_args())
    config = build_config(arguments, defaults)


"""Runs the main() function when this file is executed"""
if __name__ == '__main__':
    main(DEFAULTS, CMD_TEMPLATES, VERSION)
