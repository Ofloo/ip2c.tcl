if {[file exists ${tcl_pkgPath}/ip2c] && [file isdirectory ${tcl_pkgPath}/ip2c]} {
  file copy -force [pwd]/ip2c.tcl ${tcl_pkgPath}/ip2c
  file copy -force [pwd]/pkgIndex.tcl ${tcl_pkgPath}/ip2c
  puts stdout "Installed ip2c package."
  return
} else {
  if {[file exists ${tcl_pkgPath}/ip2c/ip2c.tcl]} {
    puts stdout "Before you install ip2c you need to deinstall previous installations."
  } else {
    file mkdir ${tcl_pkgPath}/ip2c
    file copy -force [pwd]/ip2c.tcl ${tcl_pkgPath}/ip2c
    file copy -force [pwd]/pkgIndex.tcl ${tcl_pkgPath}/ip2c
    puts stdout "Installed ip2c package."
    return
  }
}

puts stderr "Couldn't install ip2c package."
