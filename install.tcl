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

package require http
package require tls
package require Tcl 8.4

#
# Choose the first availlable path to install and check if it exists (incase of
# path with spaces)
#

foreach {pkg_Path} [concat ${tcl_pkgPath}] {
  if {[file exists ${pkg_Path}]} {
    break
  }
}

if {![file exists ${pkg_Path}]} {
  error "Couldn't determine the correct install path"
  exit 1
}

#
# returns 0 when success, returns 1 when failed returns 2 when already installed
#

if {[file exists ${pkg_Path}/ip2c] && [file isdirectory ${pkg_Path}/ip2c]} {
  if {[file exists ${pkg_Path}/ip2c/ip2c.tcl]} {
    puts stdout "Before you install ip2c you need to deinstall previous installations."
    exit 2
  } else {
    file copy -force [pwd]/ip2c.tcl ${pkg_Path}/ip2c
    file copy -force [pwd]/pkgIndex.tcl ${pkg_Path}/ip2c
    puts stdout "Installed ip2c package."
    exit 0
  }
} else {
  file mkdir ${pkg_Path}/ip2c
  file copy -force [pwd]/ip2c.tcl ${pkg_Path}/ip2c
  file copy -force [pwd]/pkgIndex.tcl ${pkg_Path}/ip2c
  puts stdout "Installed ip2c package."
  exit 0
}

error "Couldn't install ip2c package."
exit 1
