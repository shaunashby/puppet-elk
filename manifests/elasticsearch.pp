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

  yumrepo { 'elasticsearch-1.7':
    ensure   => present,
    baseurl  => 'http://packages.elastic.co/elasticsearch/1.7/centos',
    descr    => 'Elasticsearch repository for 1.7.x packages',
    gpgkey   => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
    gpgcheck => 1,
    enabled  => 1,
  }

  class { '::elasticsearch':
    version => $elk::params::es_default_version,
    config  => {
      'cluster.name'                         => $elk::params::es_cluster_name,
      'discovery.zen.ping.multicast.enabled' => false,
    },
  } -> Yumrepo['elasticsearch-1.7']

  elasticsearch::instance { $elk::params::es_instance_name:
    config  => {
      'node.name' => $elk::params::es_cnode_name
    },
    datadir => [ $elk::params::es_data_dir ],
  }
}
