# This code is licensed under the terms of the MIT License.
# Copyright (c) 2024 Alfi Maulana

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

# Attaches the Qt online installer image to a new volume.
#
# This function attaches the Qt online installer DMG image to a new volume.
# It sets the `QT_ONLINE_INSTALLER_VOLUME_PATH` variable to the location of the attached Qt online installer volume.
#
# This function does not do anything if the Qt online installer is not a DMG image.
function(_attach_qt_online_installer)
  if(NOT DEFINED QT_ONLINE_INSTALLER_PATH)
    _download_qt_online_installer()
  endif()

  get_filename_component(QT_ONLINE_INSTALLER_LAST_EXT ${QT_ONLINE_INSTALLER_PATH} LAST_EXT)
  if(QT_ONLINE_INSTALLER_LAST_EXT STREQUAL .dmg)
    get_filename_component(QT_ONLINE_INSTALLER_NAME_WLE ${QT_ONLINE_INSTALLER_PATH} NAME_WLE)
    set(QT_ONLINE_INSTALLER_VOLUME_PATH /Volumes/${QT_ONLINE_INSTALLER_NAME_WLE})

    if(NOT EXISTS ${QT_ONLINE_INSTALLER_VOLUME_PATH})
      find_program(HDIUTIL_PROGRAM hdiutil)
      if(HDIUTIL_PROGRAM STREQUAL HDIUTIL_PROGRAM-NOTFOUND)
        message(FATAL_ERROR "Could not find the 'hdiutil' program required to attach the Qt online installer")
      endif()

      execute_process(
        COMMAND ${HDIUTIL_PROGRAM} attach ${QT_ONLINE_INSTALLER_PATH}
        RESULT_VARIABLE RES
      )
      if(NOT RES EQUAL 0)
        message(FATAL_ERROR "Failed to attach the Qt online installer image at '${QT_ONLINE_INSTALLER_PATH}' to a new volume (${RES})")
      endif()
    endif()

    set(QT_ONLINE_INSTALLER_VOLUME_PATH ${QT_ONLINE_INSTALLER_VOLUME_PATH} PARENT_SCOPE)
  endif()
endfunction()
