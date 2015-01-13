#____________________________________________________________________
# File: params.pp
#____________________________________________________________________
#
# Author:  <sashby@dfi.ch>
# Created: 2015-01-08 15:00:30+0100
# Revision: $Id$
#
# Copyright (C) 2015
#
#--------------------------------------------------------------------

class elk::params {
  $ensure             = 'running'
  $es_default_version = '1.2.4-1'
  $es_instance_name   = 'DFI'
  $es_cluster_name    = 'DFI-elk'
  $es_cnode_name      = 'DFI Log Aggregator'
  $es_data_dir        = '/data/elasticsearch'
  $enable_webui       = true

  $webui_www_root = '/usr/share/kibana'
  $kibana_version = '3.1.2'

  case $::osfamily {
    'Debian': {}
    'RedHat': {
      notice("Apparently you are using the module ${module_name} from ${::osfamily}. Bravo.")
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system. Sorry.")
    }
  }
}
