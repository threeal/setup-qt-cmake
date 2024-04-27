# This code is licensed under the terms of the MIT License.
# Copyright (c) 2024 Alfi Maulana

include_guard(GLOBAL)

# Downloads the Qt online installer to a build directory.
# This function outputs a `QT_ONLINE_INSTALLER_PATH` variable indicating the location of the downloaded installer.
function(_download_qt_online_installer)
  if(CMAKE_SYSTEM_NAME STREQUAL Windows)
    set(INSTALLER_NAME qt-unified-windows-x64-4.7.0-online.exe)
    set(INSTALLER_HASH cb2dbc9f8b91a2107406a5cea60a9a6b)
  elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    set(INSTALLER_NAME qt-unified-macOS-x64-4.7.0-online.dmg)
    set(INSTALLER_HASH 40b0c04a94764db4d8ecdf37a7a8436f)
  elseif(CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(INSTALLER_NAME qt-unified-linux-x64-4.7.0-online.run)
    set(INSTALLER_HASH 3b85d14be6e179649f3eb7b92b50ae86)
  else()
    message(FATAL_ERROR "Unsupported system to download the Qt online installer: ${CMAKE_SYSTEM_NAME}")
  endif()
  set(INSTALLER_PATH ${CMAKE_BINARY_DIR}/_deps/${INSTALLER_NAME})

  file(
    DOWNLOAD
    https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/${INSTALLER_NAME}
    ${INSTALLER_PATH}
    EXPECTED_MD5 ${INSTALLER_HASH}
  )

  get_filename_component(INSTALLER_LAST_EXT ${INSTALLER_PATH} LAST_EXT)
  if(INSTALLER_LAST_EXT STREQUAL .run)
    file(
      CHMOD ${INSTALLER_PATH}
      PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    )
  endif()

  set(QT_ONLINE_INSTALLER_PATH ${INSTALLER_PATH} PARENT_SCOPE)
endfunction()

# Attaches the Qt online installer image to a new volume.
#
# This function attaches the Qt online installer DMG image to a new volume.
# It sets the `QT_ONLINE_INSTALLER_VOLUME_PATH` variable to the location of the attached Qt online installer volume
# and sets the `QT_ONLINE_INSTALLER_PROGRAM` variable to the location of the Qt online installer executable.
#
# This function does not do anything if the Qt online installer is not a DMG image,
# but it still sets the `QT_ONLINE_INSTALLER_PROGRAM` variable.
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

    set(
      QT_ONLINE_INSTALLER_PROGRAM
      ${QT_ONLINE_INSTALLER_VOLUME_PATH}/${QT_ONLINE_INSTALLER_NAME_WLE}.app/Contents/MacOS/${QT_ONLINE_INSTALLER_NAME_WLE}
      PARENT_SCOPE
    )
  else()
    set(QT_ONLINE_INSTALLER_PROGRAM ${QT_ONLINE_INSTALLER_PATH} PARENT_SCOPE)
  endif()
endfunction()

# Detaches the Qt online installer image from the volume.
#
# This function detaches the Qt online installer DMG image from the volume.
# It unsets the `QT_ONLINE_INSTALLER_VOLUME_PATH` and `QT_ONLINE_INSTALLER_PROGRAM` variables.
#
# This function does not do anything if the DMG image was not previously attached.
function(_detach_qt_online_installer)
  if(DEFINED QT_ONLINE_INSTALLER_VOLUME_PATH)
    if(EXISTS ${QT_ONLINE_INSTALLER_VOLUME_PATH})
      find_program(HDIUTIL_PROGRAM hdiutil)
      if(HDIUTIL_PROGRAM STREQUAL HDIUTIL_PROGRAM-NOTFOUND)
        message(FATAL_ERROR "Could not find the 'hdiutil' program required to detach the Qt online installer")
      endif()

      execute_process(
        COMMAND ${HDIUTIL_PROGRAM} detach ${QT_ONLINE_INSTALLER_VOLUME_PATH}
        RESULT_VARIABLE RES
      )
      if(NOT RES EQUAL 0)
        message(FATAL_ERROR "Failed to detach the Qt online installer image from '${QT_ONLINE_INSTALLER_VOLUME_PATH}' (${RES})")
      endif()
    endif()

    unset(QT_ONLINE_INSTALLER_VOLUME_PATH PARENT_SCOPE)
  endif()

  unset(QT_ONLINE_INSTALLER_PROGRAM PARENT_SCOPE)
endfunction()
