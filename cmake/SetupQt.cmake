include_guard(GLOBAL)

# Downloads the Qt online installer to a build directory.
# This function outputs a `QT_ONLINE_INSTALLER_PATH` variable indicating the location of the downloaded installer.
function(_download_qt_online_installer)
  if(WIN32)
    set(INSTALLER_NAME qt-unified-windows-x64-4.7.0-online.exe)
  elseif(APPLE)
    set(INSTALLER_NAME qt-unified-macOS-x64-4.7.0-online.dmg)
  else()
    set(INSTALLER_NAME qt-unified-linux-x64-4.7.0-online.run)
  endif()
  set(INSTALLER_PATH ${CMAKE_BINARY_DIR}/_deps/${INSTALLER_NAME})

  file(
    DOWNLOAD
    https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/${INSTALLER_NAME}
    ${INSTALLER_PATH}
  )

  set(QT_ONLINE_INSTALLER_PATH ${INSTALLER_PATH} PARENT_SCOPE)
endfunction()
