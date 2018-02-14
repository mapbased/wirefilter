#!/bin/bash -e

export CARGO_HOME=/var/lib/cargo
export CARGO_TARGET_DIR=$CARGO_HOME/target

CMD=$1
shift

PARAMS="-q $@"

set -x

case $CMD in
	prebuild)
		# Series of hacks to prebuild dependencies in a cached layer
		# (workaround for https://github.com/rust-lang/cargo/issues/2644)

		# Create dummy sources for our library
		mkdir {engine,ffi}/src
		touch {engine,ffi}/src/lib.rs

		# Build library with Cargo.lock (including all the dependencies)
		cargo build --locked --all $PARAMS

		# Clean artifacts of the library itself but keep prebuilt deps
		cargo clean --locked -p wirefilter-engine -p wirefilter-ffi $PARAMS
		;;
	*)
		# Execute any other command without special params but in same env
		cargo $CMD $PARAMS
		;;
esac
