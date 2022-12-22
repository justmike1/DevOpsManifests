#!/bin/bash

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
. $scripts_folder/utils.sh

printf "run as: ./scripts/test_args.sh --namespace mike --test true"

# default args
namespace=
test=

# read args from cli 
eval "$(read_args "$@")"

echo $namespace $test
