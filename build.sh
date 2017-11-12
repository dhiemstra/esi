#!/bin/bash

set -e

rm -f *.gem
gem build *.gemspec
FILENAME=`ls *.gem`
gem push $FILENAME
rm -f $FILENAME
