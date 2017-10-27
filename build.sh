#!/bin/bash

set -e

gem build *.gemspec
FILENAME=`ls *.gem`
gem push $FILENAME
rm -f $FILENAME
