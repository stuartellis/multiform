"""

Command builder for multi-stack Terraform.

This script requires Python 3.8 or above. It has no other dependencies.

Usage:

    python3 python/utils/utils/multiform.py init -s my-stack -e dev

Help:

    python3 python/utils/utils/multiform.py --help

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
import json
import os
from pathlib import Path
from string import Template

"""Semantic version of script"""
VERSION = "0.3.0"


"""Relevant version of Terraform stacks specification"""
TF_STACKS_SPEC_VERSION = "0.3.0"


"""Default settings"""
DEFAULTS = {
    'tf_exe': 'terraform',
    'tf_root_dir': 'terraform',
    'stackset_dir': 'stacks',
    'stacks_def_dir': 'definitions',
    'stacks_env_dir': 'environments',
}

"""Subcommands"""
SUB_COMMANDS = {
  'fmt': 'aaaa',
  'apply': 'aaaa',
  'console': 'aaaa',
  'destroy': 'aaaa',
  'init': 'aaaa',
  'plan': 'aaaa',
  'validate': 'aaaa',
}


def build_absolute_path(relative_root_path, *sub_paths):
    """Returns an absolute Path object"""
    relative_path = os.sep.join((relative_root_path,) + (sub_paths))
    path_obj = Path(relative_path)
    return path_obj.absolute()


def build_arg_parser(subcommands, version):
    """Returns a parser for the command-line arguments"""
    parser = argparse.ArgumentParser(
        description='Command builder for multi-stack Terraform.')
    parser.add_argument(
        'subcommand', choices=subcommands,
        help=f"subcommand to run: {', '.join(subcommands.keys())}")
    parser.add_argument(
        '-e', '--environment',
        help='the name of the environment.',
        required=True,
        action='store')
    parser.add_argument(
        '-i', '--instance',
        help='the instance of the stack.',
        default='',
        action='store')
    parser.add_argument(
        '--print',
        help='output generated configuration as JSON, instead of a Terraform command.',
        action='store_true')
    parser.add_argument(
        '-s', '--stack',
        help='the name of the stack.',
        required=True,
        action='store')
    parser.add_argument(
        '-v', '--version',
        help='show the version of this script and exit',
        action='version', version="%(prog)s " + version)
    return parser


def build_environment_config(name, full_path):
    return {
        'name': name.lower(),
        'varfile_path': str(full_path),
    }


def build_host_config(subcommand, defaults):
    host_config = defaults
    host_config['tf_cmd'] = subcommand
    return host_config


def build_stackset_config(name, stackset_path):
    return {
        'name': name.lower(),
        'full_path': str(stackset_path),
    }


def build_stack_config(stack, instance, stack_path, varfile_path):
    stack_config = {
       'name': stack.lower(),
       'instance': instance.lower(),
       'full_path': str(stack_path),
       'varfile_path': str(varfile_path),
    }
    return stack_config


def build_stack_path(root_path, stackset_dir, stack_name):
    """Returns a Path object for the stack directory"""
    return root_path.joinpath(stackset_dir, stack_name)


def flatten_dict(init, lkey=''):
    """
    Flattens dictionary.
    Taken from: https://stackoverflow.com/questions/6027558/flatten-nested-dictionaries-compressing-keys
    """
    ret = {}
    for rkey, val in init.items():
        key = lkey+rkey
        if isinstance(val, dict):
            ret.update(flatten_dict(val, key+'_'))
        else:
            ret[key] = val
    return ret


def render_cmd(host, stackset, stack, environment):
    # tf_aws_backend_config = f'-backend-config="bucket={}" -backend-config="key={}" -backend-config="region={}"'

    tf_var_arguments = f"-var=stack_name={stack['name']} -var=environment={environment['name']}"
    if stack['instance']:
        tf_var_arguments = tf_var_arguments + f" -var=stack_instance={stack['instance']}"
    tf_var_file_arguments = f"-var-file={stack['varfile_path']} -var-file={environment['varfile_path']}"
    tf_arguments = ' '.join([tf_var_arguments, tf_var_file_arguments])
    tf_cmd_options = '-chdir=$stack_full_path'

    cmd_template = f"$host_tf_exe {tf_cmd_options} $host_tf_cmd {tf_arguments}"
    templater = Template(cmd_template)

    config = {'host': host, 'stackset': stackset, 'stack': stack, 'environment': environment}
    cmd_context = flatten_dict(config)
    
    return templater.substitute(cmd_context)


def main(defaults, subcommands, version):
    """Main function for running script from the command-line"""
    parser = build_arg_parser(subcommands, version)
    args = vars(parser.parse_args())

    host_config = build_host_config(args['subcommand'], defaults)

    project_name = build_absolute_path(host_config['tf_root_dir']).parent.stem
    tf_stackset_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'])
    stackset_config = build_stackset_config(project_name, tf_stackset_path)

    stack_path = build_stack_path(tf_stackset_path, defaults['stacks_def_dir'], args['stack'])
    stack_varfile_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'], host_config['stacks_env_dir'], 'all', f"{args['stack']}.tfvars")
    stack_config = build_stack_config(args['stack'], args['instance'], stack_path, stack_varfile_path)

    environment_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'], host_config['stacks_env_dir'], args['environment'], f"{args['stack']}.tfvars")
    environment_config = build_environment_config(args['environment'], environment_path)

    if args['print']:
        config = {'host': host_config, 'stackset': stackset_config, 'stack': stack_config, 'environment': environment_config}
        print(json.dumps(config, indent=4))
    else:
        cmd = render_cmd(host_config, stackset_config, stack_config, environment_config)
        print(cmd)


"""Runs the main() function when this file is executed"""
if __name__ == '__main__':
    main(DEFAULTS, SUB_COMMANDS, VERSION)
