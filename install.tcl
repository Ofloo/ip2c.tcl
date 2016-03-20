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

#
# returns 0 when success, returns 1 when failed returns 2 when already installed
#

if {[file exists ${tcl_pkgPath}/ip2c] && [file isdirectory ${tcl_pkgPath}/ip2c]} {
  if {[file exists ${tcl_pkgPath}/ip2c/ip2c.tcl]} {
    puts stdout "Before you install ip2c you need to deinstall previous installations."
    return 2
  } else {
    file copy -force [pwd]/ip2c.tcl ${tcl_pkgPath}/ip2c
    file copy -force [pwd]/pkgIndex.tcl ${tcl_pkgPath}/ip2c
    puts stdout "Installed ip2c package."
    return 0
  }
} else {
  file mkdir ${tcl_pkgPath}/ip2c
  file copy -force [pwd]/ip2c.tcl ${tcl_pkgPath}/ip2c
  file copy -force [pwd]/pkgIndex.tcl ${tcl_pkgPath}/ip2c
  puts stdout "Installed ip2c package."
  return 0
}

puts stderr "Couldn't install ip2c package."

return 1
