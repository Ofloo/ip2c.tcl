#!/usr/local/bin/tclsh8.5
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

  package require http
  package require ip

  variable api "api.ip2c.info"
  variable version 1.1

  variable registry
  variable assigned
  variable short
  variable long
  variable country

  #
  #  locate ?-ip <ip>? ?-server <server?
  #  returns: -1 on invalid ip or number of results
  #

  proc locate {{list_0 {}} {list_1 {}} {list_2 {}} {list_3 {}}}  {
    variable registry; variable assigned; variable long; variable short; variable country; variable address; variable api
    foreach {key value} [info var list_?] {
      if {[set $key] == ""} {continue}
      switch -- [set ${key}] {
        "-server" {
          variable api [set $value]
        }
        "-ip" {
          set ip [set $value]
        }
        default {
          error "bad option \"[set $key]\": must be -ip or -server"
        }
      }
    }
    if {![info exists    foreach {x} [array names short] {
          lappend out $short($x)
          lappend out $long($x)
        }
      }
    }
    return $out
  }

  #
  # registry
  # returns: To which registry the IP is assigned
  #

  proc registry {}  {
    variable registry
    set out {}
    foreach {x} [array names registry] {
      lappend out $registry($x)
    }
    return $out
  }

  #
  # cleanup removes cache
  # returns: null
  #

  proc cleanup {} {
    variable registry; variable assigned; variable long; variable short; variable country; variable address
    foreach {n} "registry assigned long short country address" {
      if {[array exists [set n]]} {
        foreach {x} [array names [set n]] {
          array unset [set n] $x
        }
      }
    }
  }

  cleanup

}

package provide ip2c $::ip2c::version

