#!/usr/local/bin/tclsh8.4
################################################################################
#  
#  TCL scripts by Ofloo all rights reserved.
# 
#  HomePage: http://ofloo.net/
#  CVS: http://cvs.ofloo.net/
#  Email: support[at]ofloo.net
#  
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#   
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#   
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#   
################################################################################

namespace eval ip2c {
  
  variable version 1.0
  variable mirror "ip2c.ofloo.net"

  package require http

  proc lookup {longip {type {}}} {
    variable mirror
    if {[regexp {^[\d]{1,10}$} $longip] && (0 >= $longip <= 4294967295)} {
      if {[regexp -nocase {<resolve[\s]{0,100}c02="([a-z]{2})"[\s]{0,100}c03="([a-z]{3})"[\s]{0,100}full="(.*?)"[\s]{0,100}/>} [[namespace current]::getPage http://${mirror}/${longip}] -> tld short full]} {
        switch -- $type {
          "-tld" {
            return $tld
          }
          "-short" {
            return $short
          }
          "-full" {
            return $full
          }
          "" {
            return "$tld $short $full"
          }
        }
      }
    }
    error "bad option \"${type}\": must be -tld, -short, -full"
  }

  proc getPage {url} {
    set token [::http::geturl $url]
    set data [::http::data $token]
    ::http::cleanup $token
    return $data
  }

  # error -1
  proc ip2longip {ipaddr} {
    if {[[namespace current]::isip $ipaddr]} {
      foreach ipbyte [split $ipaddr \x2E] { 
        append hexaddr [format {%02x} $ipbyte] 
      } 
      return [format {%u} "0x$hexaddr"]
    }
    return -1
  }

  #error -1
  proc longip2ip {longip} {
    if {$longip > 4294967295} {
      return -1
    }
    return [expr {$longip>>24&255}]\x2E[expr {$longip>>16&255}]\x2E[expr {$longip>>8&255}]\x2E[expr {$longip&255}]
  }

  proc isip {ip} {
    if {[regexp {^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$} $ip -> a b c d]} {
      if {($a <= 255) && ($b <= 255) && ($c <= 255) && ($d <= 255)} {
        return 1
      }
    }
    return 0
  }

}

package provide ip2c $::ip2c::version
