# MIT License
#
# Copyright (c) 2024 Alfi Maulana
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include_guard(GLOBAL)

# Downloads the Qt online installer to a build directory.
#
# If the downloaded file is a DMG image, this function will set the 'QT_ONLINE_INSTALLER_IMAGE' variable to the
# location of the DMG image; otherwise, it will set the 'QT_ONLINE_INSTALLER_PROGRAM' variable to the location
# of the Qt online installer program.
function(_download_qt_online_installer)
  if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
    set(INSTALLER_NAME qt-unified-windows-x64-4.7.0-online.exe)
    set(INSTALLER_HASH cb2dbc9f8b91a2107406a5cea60a9a6b)
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
    set(INSTALLER_NAME qt-unified-macOS-x64-4.7.0-online.dmg)
    set(INSTALLER_HASH 40b0c04a94764db4d8ecdf37a7a8436f)
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
    set(INSTALLER_NAME qt-unified-linux-x64-4.7.0-online.run)
    set(INSTALLER_HASH 3b85d14be6e179649f3eb7b92b50ae86)
  else()
    message(FATAL_ERROR "Unsupported system to download the Qt online "
      "installer: ${CMAKE_HOST_SYSTEM_NAME}")
  endif()
  set(INSTALLER_PATH ${CMAKE_SOURCE_DIR}/.deps/${INSTALLER_NAME})

  file(
    DOWNLOAD
    https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/${INSTALLER_NAME}
    "${INSTALLER_PATH}"
    EXPECTED_MD5 "${INSTALLER_HASH}"
  )

  get_filename_component(INSTALLER_LAST_EXT "${INSTALLER_PATH}" LAST_EXT)
  if(INSTALLER_LAST_EXT STREQUAL .dmg)
    set(QT_ONLINE_INSTALLER_IMAGE "${INSTALLER_PATH}" PARENT_SCOPE)
  else()
    file(
      CHMOD "${INSTALLER_PATH}"
      PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    )
    set(QT_ONLINE_INSTALLER_PROGRAM "${INSTALLER_PATH}" PARENT_SCOPE)
  endif()
endfunction()

# Attaches the Qt online installer image to a new volume.
#
# If the 'QT_ONLINE_INSTALLER_IMAGE' variable is defined, this function will attach the Qt online installer DMG image
# to a new volume, set the `QT_ONLINE_INSTALLER_VOLUME` variable to the location of the attached Qt online installer
# volume, and set the `QT_ONLINE_INSTALLER_PROGRAM` variable to the location of the Qt online installer executable.
function(_attach_qt_online_installer)
  if(NOT DEFINED QT_ONLINE_INSTALLER_IMAGE)
    message(AUTHOR_WARNING "The 'QT_ONLINE_INSTALLER_IMAGE' variable is not defined, do nothing")
    return()
  endif()

  get_filename_component(IMAGE_NAME "${QT_ONLINE_INSTALLER_IMAGE}" NAME_WLE)
  set(VOLUME_PATH /Volumes/${IMAGE_NAME})

  if(NOT EXISTS "${VOLUME_PATH}")
    find_program(HDIUTIL_PROGRAM hdiutil)
    if(HDIUTIL_PROGRAM STREQUAL HDIUTIL_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "Could not find the 'hdiutil' program required to attach the Qt online installer")
    endif()

    execute_process(
      COMMAND "${HDIUTIL_PROGRAM}" attach "${QT_ONLINE_INSTALLER_IMAGE}"
      RESULT_VARIABLE RES
    )
    if(NOT RES EQUAL 0)
      message(
        FATAL_ERROR
        "Failed to attach the Qt online installer image at '${QT_ONLINE_INSTALLER_IMAGE}' to a new volume (${RES})"
      )
    endif()
  endif()

  set(QT_ONLINE_INSTALLER_VOLUME "${VOLUME_PATH}" PARENT_SCOPE)
  set(QT_ONLINE_INSTALLER_PROGRAM ${VOLUME_PATH}/${IMAGE_NAME}.app/Contents/MacOS/${IMAGE_NAME} PARENT_SCOPE)
endfunction()

# Detaches the Qt online installer image from the volume.
#
# If the 'QT_ONLINE_INSTALLER_VOLUME' variable is defined, this function will detach the Qt online installer DMG image
# from the volume and unset the 'QT_ONLINE_INSTALLER_VOLUME' and 'QT_ONLINE_INSTALLER_PROGRAM' variables.
function(_detach_qt_online_installer)
  if(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME)
    message(AUTHOR_WARNING "The 'QT_ONLINE_INSTALLER_VOLUME' variable is not defined, do nothing")
    return()
  endif()

  if(EXISTS "${QT_ONLINE_INSTALLER_VOLUME}")
    find_program(HDIUTIL_PROGRAM hdiutil)
    if(HDIUTIL_PROGRAM STREQUAL HDIUTIL_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "Could not find the 'hdiutil' program required to detach the Qt online installer")
    endif()

    execute_process(
      COMMAND "${HDIUTIL_PROGRAM}" detach "${QT_ONLINE_INSTALLER_VOLUME}"
      RESULT_VARIABLE RES
    )
    if(NOT RES EQUAL 0)
      message(
        FATAL_ERROR
        "Failed to detach the Qt online installer image from '${QT_ONLINE_INSTALLER_VOLUME}' (${RES})"
      )
    endif()
  endif()

  unset(QT_ONLINE_INSTALLER_VOLUME PARENT_SCOPE)
  if(QT_ONLINE_INSTALLER_PROGRAM MATCHES "^${QT_ONLINE_INSTALLER_VOLUME}")
    unset(QT_ONLINE_INSTALLER_PROGRAM PARENT_SCOPE)
  endif()
endfunction()
