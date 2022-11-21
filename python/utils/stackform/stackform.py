"""

Command builder for Terraform with stacks.

This script requires Python 3.8 or above. It has no other dependencies.

Usage:

    python3 python/utils/stackform/stackform.py init -s my-stack -e dev

Help:

    python3 python/utils/utils/stackform.py --help

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


"""Semantic version of script"""
VERSION = "0.4.0"


"""Relevant version of Terraform stacks specification"""
TF_STACKS_SPEC_VERSION = "0.4.0"


"""Default settings"""
DEFAULTS = {
    'tf_exe': 'terraform',
    'tf_root_dir': 'terraform1',
    'stackset_dir': 'stacks',
    'stacks_def_dir': 'definitions',
    'stacks_env_dir': 'environments',
    'backend_file_name': 'backend.json',
    'backend_type': 'aws',
}


"""Subcommands"""
SUB_COMMANDS = [
  'fmt',
  'apply',
  'console',
  'destroy',
  'init',
  'plan',
  'validate',
]


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
        help=f"subcommand to run: {', '.join(subcommands)}")
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
        '--disconnected',
        help='Disable Terraform backend.',
        action='store_true')
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


def build_environment_config(name, backend_file_path, tfvars_file_path):
    return {
        'name': name.lower(),
        'backend_file_path': str(backend_file_path),
        'tfvars_file_path': str(tfvars_file_path),
        'backend': load_json(backend_file_path)
    }


def build_host_config(subcommand, defaults):
    host_config = defaults
    host_config['tf_cmd'] = subcommand
    return host_config


def build_instance_config(name, environment_name, stack_name):
    identifier = ''
    workspace = 'default'

    if name:
        identifier = name.lower() + '-'
        workspace = name.lower()

    return {
        'name': name.lower(),
        'identifier': identifier,
        'state_key': '/'.join(['stacks', environment_name, stack_name, ]),
        'workspace': workspace,
    }


def build_stackset_config(name, stackset_path):
    return {
        'name': name.lower(),
        'full_path': str(stackset_path),
    }


def build_stack_config(name, stack_path, tfvars_file_path):
    stack_config = {
       'name': name.lower(),
       'full_path': str(stack_path),
       'tfvars_file_path': str(tfvars_file_path),
    }
    return stack_config


def build_stack_path(root_path, stackset_dir, stack_name):
    """Returns a Path object for the stack directory"""
    return root_path.joinpath(stackset_dir, stack_name)


def load_json(file_path):
    """Returns the contents of a JSON file"""
    with open(file_path) as f:
        return json.load(f)


def render_tf_cmd(host, stackset, stack, environment, instance):
    """Returns a string for the required Terraform command"""

    cmd_elements = []

    cmd_elements.append(f"TF_WORKSPACE={instance['workspace']}")
    cmd_elements.append(host['tf_exe'])

    tf_cmd_options = f"-chdir={stack['full_path']}"
    cmd_elements.append(tf_cmd_options)

    cmd_elements.append(host['tf_cmd'])

    tf_var_arguments = f"-var=stack_name={stack['name']} -var=environment={environment['name']}"
    if instance['identifier']:
        tf_var_arguments = tf_var_arguments + f" -var=instance_identifier={instance['identifier']}"
    tf_var_file_arguments = f"-var-file={stack['tfvars_file_path']} -var-file={environment['tfvars_file_path']}"
    tf_arguments = ' '.join([tf_var_arguments, tf_var_file_arguments])

    if host['tf_cmd'] != 'fmt':
        cmd_elements.append(tf_arguments)

    if host['tf_cmd'] == 'init' and not host['backend_type'] == 'DISCONNECTED':
        backend_configs = environment['backend'][host['backend_type']]
        backend_configs['key'] = instance['state_key']
        backend_config_arguments = [f'-backend-config="{k}={v}"' for k, v in backend_configs.items()]
        cmd_elements = cmd_elements + backend_config_arguments

    cmd = ' '.join(cmd_elements)
    return cmd


def main(defaults, subcommands, version, stacks_spec_version):
    """Main function for running script from the command-line"""
    parser = build_arg_parser(subcommands, version)
    args = vars(parser.parse_args())
    settings = defaults
    settings['stacks_spec_version'] = stacks_spec_version
    if args['disconnected']:
        settings['backend_type'] = 'DISCONNECTED'
    host_config = build_host_config(args['subcommand'], settings)

    project_name = build_absolute_path(host_config['tf_root_dir']).parent.stem
    tf_stackset_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'])
    stackset_config = build_stackset_config(project_name, tf_stackset_path)

    stack_path = build_stack_path(tf_stackset_path, defaults['stacks_def_dir'], args['stack'])
    stack_varfile_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'], host_config['stacks_env_dir'], 'all', f"{args['stack']}.tfvars")
    stack_config = build_stack_config(args['stack'], stack_path, stack_varfile_path)

    environment_backend_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'], host_config['stacks_env_dir'], args['environment'], host_config['backend_file_name'])
    environment_tfvars_path = build_absolute_path(host_config['tf_root_dir'], host_config['stackset_dir'], host_config['stacks_env_dir'], args['environment'], f"{args['stack']}.tfvars")
    environment_config = build_environment_config(args['environment'], environment_backend_path, environment_tfvars_path)

    instance_config = build_instance_config(args['instance'], environment_config['name'], stack_config['name'])

    if args['print']:
        config = {'host': host_config, 'stackset': stackset_config, 'stack': stack_config, 'environment': environment_config, 'instance': instance_config}
        print(json.dumps(config, indent=2, sort_keys=True))
    else:
        cmd = render_tf_cmd(host_config, stackset_config, stack_config, environment_config, instance_config)
        print(cmd)


"""Runs the main() function when this file is executed"""
if __name__ == '__main__':
    main(DEFAULTS, SUB_COMMANDS, VERSION, TF_STACKS_SPEC_VERSION)
