#____________________________________________________________________ 
# File: kibana.pp
#____________________________________________________________________ 
#  
# Author:  <sashby@dfi.ch>
# Created: 2015-01-12 12:37:35+0100
# Revision: $Id$ 
#
# Copyright (C) 2015 
#
#--------------------------------------------------------------------
class elk::kibana($src_root='/tmp',$version='3.1.2', $kibana_dashboard_name='default') {

  file { "kibana ${version} source tree":
    ensure  => directory,
    path    => "${src_root}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    recurse => true,
    source  => "puppet:///modules/elk/usr/share/kibana-${version}",
  }

  $kibana_def_route="/dashboard/file/${kibana_dashboard_name}.json"

  # Manage our dashboard:
  file { 'default dashboard':
    path    => "${src_root}/src/app/dashboards/${kibana_dashboard_name}.json",
    content => template("elk/usr/share/kibana/src/app/dashboards/${kibana_dashboard_name}.json.erb"),
  }

  # Core Kibana configuration file (for version 3.x.x). This will set the default dashboard
  # to load from the landing page and the name of the dashboard:
  file { 'kibana config.js':
    path    => "${src_root}/src/config.js",
    content => template('elk/usr/share/kibana/src/config.js.erb'),
  }
}
