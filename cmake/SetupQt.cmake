include_guard(GLOBAL)

# Downloads the Qt online installer to a build directory.
# This function outputs a `QT_ONLINE_INSTALLER_PATH` variable indicating the location of the downloaded installer.
function(_download_qt_online_installer)
  if(WIN32)
    set(INSTALLER_NAME qt-unified-windows-x64-4.7.0-online.exe)
    set(INSTALLER_HASH cb2dbc9f8b91a2107406a5cea60a9a6b)
  elseif(APPLE)
    set(INSTALLER_NAME qt-unified-macOS-x64-4.7.0-online.dmg)
    set(INSTALLER_HASH 40b0c04a94764db4d8ecdf37a7a8436f)
  else()
    set(INSTALLER_NAME qt-unified-linux-x64-4.7.0-online.run)
    set(INSTALLER_HASH 3b85d14be6e179649f3eb7b92b50ae86)
  endif()
  set(INSTALLER_PATH ${CMAKE_BINARY_DIR}/_deps/${INSTALLER_NAME})

  file(
    DOWNLOAD
    https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/${INSTALLER_NAME}
    ${INSTALLER_PATH}
    EXPECTED_MD5 ${INSTALLER_HASH}
  )

  set(QT_ONLINE_INSTALLER_PATH ${INSTALLER_PATH} PARENT_SCOPE)
endfunction()
