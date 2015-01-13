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
class elk::kibana($src_root='/tmp',$version='3.1.2') {
  notice("${class} not yet configured.")

  file { "kibana ${version} source tree" :
    path    => "${src_root}",
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/elk/usr/share/kibana-${version}",
  }
}
