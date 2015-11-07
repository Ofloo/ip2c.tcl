#!/usr/local/bin/tclsh8.5
################################################################################
#
#  TCL scripts by Ofloo all rights reserved.
#
#  HomePage: http://ofloo.net/
#  GIT: https://github.com/Ofloo/ip2c.tcl
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
  variable version 1.2.1

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
    if {![info exists ip]} {set ip {}}
    set out "0"
    if {[ip::is ipv4 $ip] || [ip::is ipv6 $ip] || ($ip == "")} {
      set url "http://${api}/csv/${ip}"
      while {1} {
        if {![catch {http::geturl $url} tok]} {
          switch -glob -- [http::ncode $tok] {
            30[1237] {
              upvar #0 $tok state
              array set meta $state(meta)
              if {[info exists meta(Location)]} {
                if {![string equal {} $meta(Location)]} {
                  set url [split $meta(Location)]
                  http::cleanup $tok
                } else {
                  break
                }
              } else {
                break
              }
            }
            default {
              break
            }
          }
        } else {
          break
        }
      }

      set dat [http::data $tok]
      http::cleanup $tok
      cleanup
      foreach {-> ip a02 a03 coun reg time} [regexp -all -nocase -inline {"(.*?)","([a-z]{2})","([a-z]{3})","(.*?)","([a-z]+)","([0-9]+)"} $dat] {
        array set registry [list $out $reg]
        array set assigned [list $out $time]
        array set short [list $out $a02]
        array set long [list $out $a03]
        array set country [list $out $coun]
        array set address [list $out [ip::prefix $ip]]
        incr out
      }
    } else {
      return -1
    }
    return $out
  }

  #
  # address
  # returns: IP where the lookup was made upon
  #

  proc address {}  {
    variable address
    set out {}
    foreach {x} [array names address] {
      lappend out $address($x)
      break
    }
    return $out
  }

  #
  # country
  # returns: Full name country name
  #

  proc country {}  {
    variable country
    set out {}
    foreach {x} [array names country] {
      lappend out $country($x)
    }
    return $out
  }

  #
  # assigned
  # returns: The time in seconds when the space was allocated
  #

  proc assigned {}  {
    variable assigned
    set out {}
    foreach {x} [array names assigned] {
      lappend out $assigned($x)
    }
    return $out
  }

  #
  # abbr ?-short|-long?
  # returns: Country abbreviation when -short 2 char type is returned when -long 3 char
  # type is returned when null all types are returned
  #

  proc abbr {{type {}}}  {
    variable long; variable short
    set out {}
    switch -- $type {
      "-short" {
        foreach {x} [array names short] {
          lappend out $short($x)
        }
      }
      "-long" {
        foreach {x} [array names long] {
          lappend out $long($x)
        }
      }
      default {
        foreach {x} [array names short] {
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
