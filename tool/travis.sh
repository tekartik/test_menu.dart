#!/bin/bash

# Fast fail the script on failures.
set -e

# for debugging
pub run chrome_travis:show_env

dartanalyzer --fatal-warnings lib

pub run test -p vm,firefox,chrome
