# == Class: elk
#
# A class used to manage an ELK stack
#
# === Parameters
#
# Document parameters here.
#
# [*ensure*]
#   Make sure that the stack is running.
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'elk': }
#
# === Authors
#
# Shaun Ashby <sashby@dfi.ch>
#
# === Copyright
#
# Copyright 2014 Shaun ASHBY, DFI Service SA.
#
class elk(
  $ensure = $elk::params::ensure
  ) inherits elk::params {
}
