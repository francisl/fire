# 🔥 - Live reload for Mojo Applications

Watch the directory containing the target file
and automatically recompile when .mojo or .py files change.

## Motivation

Be faster to develop mojo long running mojo application like web server.

## Features

- Scan .mojo and .py files
- Build and rerun the program

### To be added

- custom build command
- Help flag
- script install
- package install
- User native watcher when binding for mojo are available/possible like libuv or inotify-tools.

## Use

Usage: fire <target_mojo_file>
Example: 

> fire src/main.mojo

## Install

> git clone https://github.com/francisl/fire.git
> cd fire
> mojo build src/fire.mojo

This will create a binary `fire`

> cp fire /somewhere/in/your/PATH
