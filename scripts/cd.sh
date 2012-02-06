#!/bin/bash

# changes the current working directory to the
# sinatra project root before executing the given
# ruby script with the given ruby binary

# usage:
# ./cd.sh "/path/to/ruby/wrapper/or/binary" "path/to/script/relative/to/project/root"

# example:
# ./cd.sh "/usr/local/rvm/wrappers/ruby-1.9.2-p290/ruby" "scripts/intake.rb"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$DIR/.."

cat - | $1 "$DIR/../$2"
