# useful-sh

My useful Shell scripts to help making automated tasks

## Instructions

There are two kinds of scripts:

- command-like: works like a comand-line tool
- helpers scripts: utilities to be imported in your own Bash scripts

### Using helpers scripts

- Copy the desired files to your project
- Then in your script import it:

```sh
#!/bin/bash

source "helpers/logger.sh"
source "helpers/git-utils.sh"

# Or you want to use absolute paths:

# Get current directory
SCRIPT_DIR_NAME=`dirname "$0"`

source "$SCRIPT_DIR_NAME/helpers/logger.sh"
source "$SCRIPT_DIR_NAME/helpers/git-utils.sh"
```
