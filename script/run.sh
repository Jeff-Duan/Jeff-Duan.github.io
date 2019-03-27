#!/bin/sh

set -e

bundle install "$@"

bundle exec jekyll serve --livereload