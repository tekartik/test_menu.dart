#!/usr/bin/env bash

set -xe

pushd test_menu
pub get
tool/travis.sh
popd

pushd test_menu_io
pub get
tool/travis.sh
popd
