
"""

Command builder for multi-stack Terraform.

This script has the following dependencies:

* Python 3.8 or above
* Terraform 1.0 or above

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

from pathlib import Path
from string import Template


"""Semantic version of script"""
VERSION = "0.1.0"


"""Relevant version of Terraform stacks specification"""
TF_STACKS_SPEC_VERSION = "0.1.0"


"""Default settings"""
DEFAULTS = {
    'tf_exe': 'terraform',
    'tf_root_dir': 'terraform',
    'tf_stacks_dir': 'stacks',
}


"""Templates for Terraform subcommands"""
CMD_TEMPLATES = {
    'apply': 'FIXME',
    'console': '$tf_exe -chdir=$tf_stack_path console',
    'destroy': 'FIXME',
    'fmt': '$tf_exe -chdir=$tf_stack_path fmt',
    'init': '$tf_exe -chdir=$tf_stack_path init',
    'plan': 'FIXME',
    'validate': '$tf_exe -chdir=$tf_stack_path validate',
}


def build_arg_parser(subcommands, version):
    """Creates the parser for the command-line arguments"""
    parser = argparse.ArgumentParser(
        description='Command builder for multi-stack Terraform.')
    parser.add_argument(
        'subcommand', choices=subcommands,
        help=f"subcommand to run: {', '.join(subcommands.keys())}")
    parser.add_argument(
        '-e', '--environment',
        help='the name of the environment.',
        action='store')
    parser.add_argument(
        '-s', '--stack',
        help='the name of the stack.',
        action='store')
    parser.add_argument(
        '-v', '--version',
        help='show the version of this script and exit',
        action='version', version="%(prog)s " + version)
    return parser


def build_config(args, defaults):
    """Creates a configuration"""
    config = defaults
    project_path = build_project_path(defaults['tf_root_dir'])
    stack_path = build_stack_path(project_path, defaults['tf_stacks_dir'], args['stack'])
    config['tf_stack_path'] = stack_path
    return config


def build_context(config):
    """Creates a template context"""
    return config


def build_project_path(root_path):
    """Returns the absolute path to the project"""
    relative_path = Path(root_path)
    return relative_path.absolute()


def build_stack_path(root_path, stack_dir, stack_name):
    """Returns the path to the stack"""
    stack_path = root_path.joinpath(stack_dir, stack_name)
    return stack_path


def render(template, context):
    """Renders a string from a template"""
    templater = Template(template)
    return templater.substitute(context)


def main(defaults, commands, version):
    """Main function for running script from the command-line"""
    parser = build_arg_parser(commands, version)
    args = vars(parser.parse_args())
    config = build_config(args, defaults)
    context = build_context(config)
    selected_cmd = args['subcommand']
    cmd = render(commands[selected_cmd], context)
    print(cmd)


"""Runs the main() function when this file is executed"""
if __name__ == '__main__':
    main(DEFAULTS, CMD_TEMPLATES, VERSION)
