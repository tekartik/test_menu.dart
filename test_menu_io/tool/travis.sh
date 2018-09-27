#!/usr/bin/env bash


# Fast fail the script on failures.
set -e


dartanalyzer --fatal-warnings lib

pub run test -p vm
