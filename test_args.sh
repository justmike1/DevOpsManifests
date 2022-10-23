#!/bin/bash

# run as: ./test_args --namespace mike --test true

. ./bash_utils.sh

# default args
namespace=
test=

# read args from cli 
eval "$(read_args "$@")"

echo $namespace $test
