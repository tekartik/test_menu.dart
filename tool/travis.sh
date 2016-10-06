#!/bin/bash

# Fast fail the script on failures.
set -e

# for debugging
pub run chrome_travis:show_env

dartanalyzer --fatal-warnings \
  lib/test_menu_browser.dart \
  lib/test_menu_mdl_browser.dart \
  lib/test_menu_console.dart

pub run test -p vm,firefox,chrome
