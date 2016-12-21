# -*- encoding : utf-8 -*-
require 'rubygems'
gemfile = File.expand_path("<%= gemfile_path %>", __FILE__)

ENV['BUNDLE_GEMFILE'] = gemfile
require 'bundler'
Bundler.setup
