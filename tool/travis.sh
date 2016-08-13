#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/test_menu_mdl_browser.dart \
  lib/test_menu_console.dart

pub run test -p vm,firefox