#!/usr/bin/env bash

source ~/.rvm/scripts/rvm
rvm use default
git checkout Example/Podfile.lock # Hack for avoiding git error
pod trunk push