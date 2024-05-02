# This code is licensed under the terms of the MIT License.
# Copyright (c) 2024 Alfi Maulana

include_guard(GLOBAL)

function(_install_missing_deps PROGRAM)
  find_program(READELF_PROGRAM readelf)
  if(READELF_PROGRAM STREQUAL READELF_PROGRAM-NOTFOUND)
    message(
      AUTHOR_WARNING
      "Could not find the 'readelf' program required to determine the dependencies of '${PROGRAM}', skipping dependencies installation"
    )
    return()
  endif()

  execute_process(
    COMMAND ${READELF_PROGRAM} -d ${PROGRAM}
    RESULT_VARIABLE RES
    OUTPUT_VARIABLE OUT
  )
  if(NOT RES EQUAL 0)
    message(
      AUTHOR_WARNING
      "Failed to determine the dependencies of '${PROGRAM}', skipping dependencies installation (${RES})"
    )
  endif()

  message(FATAL_ERROR ${OUT})
endfunction()

# Downloads the Qt online installer to a build directory.
#
# If the downloaded file is a DMG image, this function will set the 'QT_ONLINE_INSTALLER_IMAGE' variable to the
# location of the DMG image; otherwise, it will set the 'QT_ONLINE_INSTALLER_PROGRAM' variable to the location
# of the Qt online installer program.
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
  if(INSTALLER_LAST_EXT STREQUAL .dmg)
    set(QT_ONLINE_INSTALLER_IMAGE ${INSTALLER_PATH} PARENT_SCOPE)
  else()
    file(
      CHMOD ${INSTALLER_PATH}
      PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    )

    if(INSTALLER_LAST_EXT STREQUAL .run)
      _install_missing_deps("${INSTALLER_PATH}")
    endif()

    set(QT_ONLINE_INSTALLER_PROGRAM ${INSTALLER_PATH} PARENT_SCOPE)
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

  get_filename_component(IMAGE_NAME ${QT_ONLINE_INSTALLER_IMAGE} NAME_WLE)
  set(VOLUME_PATH /Volumes/${IMAGE_NAME})

  if(NOT EXISTS ${VOLUME_PATH})
    find_program(HDIUTIL_PROGRAM hdiutil)
    if(HDIUTIL_PROGRAM STREQUAL HDIUTIL_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "Could not find the 'hdiutil' program required to attach the Qt online installer")
    endif()

    execute_process(
      COMMAND ${HDIUTIL_PROGRAM} attach ${QT_ONLINE_INSTALLER_IMAGE}
      RESULT_VARIABLE RES
    )
    if(NOT RES EQUAL 0)
      message(
        FATAL_ERROR
        "Failed to attach the Qt online installer image at '${QT_ONLINE_INSTALLER_IMAGE}' to a new volume (${RES})"
      )
    endif()
  endif()

  set(QT_ONLINE_INSTALLER_VOLUME ${VOLUME_PATH} PARENT_SCOPE)
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

  if(EXISTS ${QT_ONLINE_INSTALLER_VOLUME})
    find_program(HDIUTIL_PROGRAM hdiutil)
    if(HDIUTIL_PROGRAM STREQUAL HDIUTIL_PROGRAM-NOTFOUND)
      message(FATAL_ERROR "Could not find the 'hdiutil' program required to detach the Qt online installer")
    endif()

    execute_process(
      COMMAND ${HDIUTIL_PROGRAM} detach ${QT_ONLINE_INSTALLER_VOLUME}
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

# Sets up the latest version of the Qt framework.
#
# This function will set the 'QT_CMAKE_PREFIX_PATH' variable to the CMake prefix path of the Qt framework.
function(setup_qt)
  _download_qt_online_installer()
  if(DEFINED QT_ONLINE_INSTALLER_IMAGE)
    _attach_qt_online_installer()
  endif()

  set(ROOT_PATH ${CMAKE_BINARY_DIR}/_deps/qt)
  if(CMAKE_SYSTEM_NAME STREQUAL Windows)
    set(CMAKE_PREFIX_PATH ${ROOT_PATH}/6.5.3/msvc2019_64/lib/cmake)
  elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    set(CMAKE_PREFIX_PATH ${ROOT_PATH}/6.5.3/macos/lib/cmake)
  elseif(CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(CMAKE_PREFIX_PATH ${ROOT_PATH}/6.5.3/gcc_64/lib/cmake)
  else()
    message(FATAL_ERROR "Unsupported system to set up the Qt framework: ${CMAKE_SYSTEM_NAME}")
  endif()

  if(NOT EXISTS ${CMAKE_PREFIX_PATH})
    if(CMAKE_SYSTEM_NAME STREQUAL Windows)
      set(PACKAGE_NAME qt.qt6.653.win64_msvc2019_64)
    elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
      set(PACKAGE_NAME qt.qt6.653.clang_64)
    elseif(CMAKE_SYSTEM_NAME STREQUAL Linux)
      set(PACKAGE_NAME qt.qt6.653.gcc_64)
    else()
      message(FATAL_ERROR "Unsupported system to set up the Qt framework: ${CMAKE_SYSTEM_NAME}")
    endif()

    execute_process(
      COMMAND ${QT_ONLINE_INSTALLER_PROGRAM}
        --root ${ROOT_PATH}
        --accept-licenses
        --accept-obligations
        --default-answer
        --confirm-command
        install ${PACKAGE_NAME}
      RESULT_VARIABLE RES
    )
    if(NOT RES EQUAL 0)
      message(FATAL_ERROR "Failed to set up the latest Qt framework (${RES})")
    endif()

    if(DEFINED QT_ONLINE_INSTALLER_VOLUME)
      _detach_qt_online_installer()
    endif()
  endif()

  set(QT_CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)
endfunction()
