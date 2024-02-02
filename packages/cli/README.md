oclif-hello-world
=================

oclif example Hello World CLI

[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)
[![CircleCI](https://circleci.com/gh/oclif/hello-world/tree/main.svg?style=shield)](https://circleci.com/gh/oclif/hello-world/tree/main)
[![GitHub license](https://img.shields.io/github/license/oclif/hello-world)](https://github.com/oclif/hello-world/blob/main/LICENSE)

<!-- toc -->
* [Usage](#usage)
* [Commands](#commands)
<!-- tocstop -->
# Usage
<!-- usage -->
```sh-session
$ npm install -g bojcli
$ boj COMMAND
running command...
$ boj (--version)
bojcli/0.0.0 linux-x64 node-v18.14.1
$ boj --help [COMMAND]
USAGE
  $ boj COMMAND
...
```
<!-- usagestop -->
# Commands
<!-- commands -->
* [`boj hello PERSON`](#boj-hello-person)
* [`boj hello world`](#boj-hello-world)
* [`boj help [COMMANDS]`](#boj-help-commands)
* [`boj plugins`](#boj-plugins)
* [`boj plugins:install PLUGIN...`](#boj-pluginsinstall-plugin)
* [`boj plugins:inspect PLUGIN...`](#boj-pluginsinspect-plugin)
* [`boj plugins:install PLUGIN...`](#boj-pluginsinstall-plugin-1)
* [`boj plugins:link PLUGIN`](#boj-pluginslink-plugin)
* [`boj plugins:uninstall PLUGIN...`](#boj-pluginsuninstall-plugin)
* [`boj plugins reset`](#boj-plugins-reset)
* [`boj plugins:uninstall PLUGIN...`](#boj-pluginsuninstall-plugin-1)
* [`boj plugins:uninstall PLUGIN...`](#boj-pluginsuninstall-plugin-2)
* [`boj plugins update`](#boj-plugins-update)

## `boj hello PERSON`

Say hello

```
USAGE
  $ boj hello PERSON -f <value>

ARGUMENTS
  PERSON  Person to say hello to

FLAGS
  -f, --from=<value>  (required) Who is saying hello

DESCRIPTION
  Say hello

EXAMPLES
  $ oex hello friend --from oclif
  hello friend from oclif! (./src/commands/hello/index.ts)
```

_See code: [src/commands/hello/index.ts](https://github.com/bank-of-jubjub/base/blob/v0.0.0/src/commands/hello/index.ts)_

## `boj hello world`

Say hello world

```
USAGE
  $ boj hello world

DESCRIPTION
  Say hello world

EXAMPLES
  $ boj hello world
  hello world! (./src/commands/hello/world.ts)
```

_See code: [src/commands/hello/world.ts](https://github.com/bank-of-jubjub/base/blob/v0.0.0/src/commands/hello/world.ts)_

## `boj help [COMMANDS]`

Display help for boj.

```
USAGE
  $ boj help [COMMANDS] [-n]

ARGUMENTS
  COMMANDS  Command to show help for.

FLAGS
  -n, --nested-commands  Include all nested commands in the output.

DESCRIPTION
  Display help for boj.
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v5.2.20/src/commands/help.ts)_

## `boj plugins`

List installed plugins.

```
USAGE
  $ boj plugins [--json] [--core]

FLAGS
  --core  Show core plugins.

GLOBAL FLAGS
  --json  Format output as json.

DESCRIPTION
  List installed plugins.

EXAMPLES
  $ boj plugins
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/index.ts)_

## `boj plugins:install PLUGIN...`

Installs a plugin into the CLI.

```
USAGE
  $ boj plugins add plugins:install PLUGIN...

ARGUMENTS
  PLUGIN  Plugin to install.

FLAGS
  -f, --force    Run yarn install with force flag.
  -h, --help     Show CLI help.
  -s, --silent   Silences yarn output.
  -v, --verbose  Show verbose yarn output.

GLOBAL FLAGS
  --json  Format output as json.

DESCRIPTION
  Installs a plugin into the CLI.
  Can be installed from npm or a git url.

  Installation of a user-installed plugin will override a core plugin.

  e.g. If you have a core plugin that has a 'hello' command, installing a user-installed plugin with a 'hello' command
  will override the core plugin implementation. This is useful if a user needs to update core plugin functionality in
  the CLI without the need to patch and update the whole CLI.


ALIASES
  $ boj plugins add

EXAMPLES
  $ boj plugins add myplugin 

  $ boj plugins add https://github.com/someuser/someplugin

  $ boj plugins add someuser/someplugin
```

## `boj plugins:inspect PLUGIN...`

Displays installation properties of a plugin.

```
USAGE
  $ boj plugins inspect PLUGIN...

ARGUMENTS
  PLUGIN  [default: .] Plugin to inspect.

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

GLOBAL FLAGS
  --json  Format output as json.

DESCRIPTION
  Displays installation properties of a plugin.

EXAMPLES
  $ boj plugins inspect myplugin
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/inspect.ts)_

## `boj plugins:install PLUGIN...`

Installs a plugin into the CLI.

```
USAGE
  $ boj plugins install PLUGIN...

ARGUMENTS
  PLUGIN  Plugin to install.

FLAGS
  -f, --force    Run yarn install with force flag.
  -h, --help     Show CLI help.
  -s, --silent   Silences yarn output.
  -v, --verbose  Show verbose yarn output.

GLOBAL FLAGS
  --json  Format output as json.

DESCRIPTION
  Installs a plugin into the CLI.
  Can be installed from npm or a git url.

  Installation of a user-installed plugin will override a core plugin.

  e.g. If you have a core plugin that has a 'hello' command, installing a user-installed plugin with a 'hello' command
  will override the core plugin implementation. This is useful if a user needs to update core plugin functionality in
  the CLI without the need to patch and update the whole CLI.


ALIASES
  $ boj plugins add

EXAMPLES
  $ boj plugins install myplugin 

  $ boj plugins install https://github.com/someuser/someplugin

  $ boj plugins install someuser/someplugin
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/install.ts)_

## `boj plugins:link PLUGIN`

Links a plugin into the CLI for development.

```
USAGE
  $ boj plugins link PLUGIN

ARGUMENTS
  PATH  [default: .] path to plugin

FLAGS
  -h, --help          Show CLI help.
  -v, --verbose
      --[no-]install  Install dependencies after linking the plugin.

DESCRIPTION
  Links a plugin into the CLI for development.
  Installation of a linked plugin will override a user-installed or core plugin.

  e.g. If you have a user-installed or core plugin that has a 'hello' command, installing a linked plugin with a 'hello'
  command will override the user-installed or core plugin implementation. This is useful for development work.


EXAMPLES
  $ boj plugins link myplugin
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/link.ts)_

## `boj plugins:uninstall PLUGIN...`

Removes a plugin from the CLI.

```
USAGE
  $ boj plugins remove plugins:uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Removes a plugin from the CLI.

ALIASES
  $ boj plugins unlink
  $ boj plugins remove

EXAMPLES
  $ boj plugins remove myplugin
```

## `boj plugins reset`

Remove all user-installed and linked plugins.

```
USAGE
  $ boj plugins reset
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/reset.ts)_

## `boj plugins:uninstall PLUGIN...`

Removes a plugin from the CLI.

```
USAGE
  $ boj plugins uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Removes a plugin from the CLI.

ALIASES
  $ boj plugins unlink
  $ boj plugins remove

EXAMPLES
  $ boj plugins uninstall myplugin
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/uninstall.ts)_

## `boj plugins:uninstall PLUGIN...`

Removes a plugin from the CLI.

```
USAGE
  $ boj plugins unlink plugins:uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Removes a plugin from the CLI.

ALIASES
  $ boj plugins unlink
  $ boj plugins remove

EXAMPLES
  $ boj plugins unlink myplugin
```

## `boj plugins update`

Update installed plugins.

```
USAGE
  $ boj plugins update [-h] [-v]

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Update installed plugins.
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v4.1.8/src/commands/plugins/update.ts)_
<!-- commandsstop -->
