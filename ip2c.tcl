#!/usr/local/bin/tclsh8.5
################################################################################
#
#  TCL scripts by Ofloo all rights reserved.
#
#  HomePage: http://ofloo.net/
#  GIT: https://github.com/Ofloo/ip2c.tcl
#  Email: support[at]ofloo.net
#
#  Copyright (c) 2017, Wouter Snels
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. All advertising materials mentioning features or use of this software
#     must display the following acknowledgement:
#     This product includes software developed by the <organization>.
#  4. Neither the name of the <organization> nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
################################################################################

namespace eval ip2c {

  package require http
  package require ip
  package require tls
  package require Tcl 8.4

  variable api "api.ip2c.info"
  variable version 1.3.0

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
      http::register https 443 tls::socket
      set url "https://${api}/csv/${ip}"
      while {1} {
        if {![catch {http::geturl $url -timeout 30000} tok]} {
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
      http::unregister https
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
