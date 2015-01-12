#____________________________________________________________________ 
# File: elasticsearch.pp
#____________________________________________________________________ 
#  
# Author:  <sashby@dfi.ch>
# Created: 2015-01-09 11:06:20+0100
# Revision: $Id$ 
#
# Copyright (C) 2015 
#
#--------------------------------------------------------------------
class elk::elasticsearch() inherits elk::params {
  class { '::elasticsearch': }

  elasticsearch::instance { "${es_instance_name}":
    config  => { 'node.name' => 'DFI Log Aggregator' },
    datadir => [ $es_data_dir ],
  }
}