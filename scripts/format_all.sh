#!/bin/bash

success=0

p_args=(--write)
p_log="Running prettier"
log="Running black & isort"

if [[ "$1" = "--check" || "$1" = "-c" ]]; then
	log="$log in check only mode"
	p_log="$p_log in check only mode"
	args=(--check)
	p_args=(--check)
fi

echo "$log..."

black tools "${args[@]}" && black tests "${args[@]}"
isort tools "${args[@]}" && isort tests "${args[@]}"

echo "$p_log..."

npx prettier . "${p_args[@]}"
if [ $? -ne 0 ]; then
	success=1
fi

exit $success
