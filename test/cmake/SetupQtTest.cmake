# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

include(SetupQt)

set(TEST_COUNT 0)

if("Download Qt online installer" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  _download_qt_online_installer()

  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    if(NOT DEFINED QT_ONLINE_INSTALLER_IMAGE)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_IMAGE' variable should be defined")
    elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_IMAGE})
      message(FATAL_ERROR "The downloaded installer image should exist at '${QT_ONLINE_INSTALLER_IMAGE}'")
    elseif(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should not be defined")
    endif()
  else()
    if(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should be defined")
    elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_PROGRAM})
      message(FATAL_ERROR "The downloaded installer program should exist at '${QT_ONLINE_INSTALLER_PROGRAM}'")
    elseif(DEFINED QT_ONLINE_INSTALLER_IMAGE)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_IMAGE' variable should not be defined")
    endif()
  endif()
endif()

if("Attach and detach Qt online installer" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  _download_qt_online_installer()
  _attach_qt_online_installer()

  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    if(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_VOLUME' variable should be defined")
    elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_VOLUME})
      message(FATAL_ERROR "The attached installer should exist at '${QT_ONLINE_INSTALLER_VOLUME}'")
    endif()
  else()
    if(DEFINED QT_ONLINE_INSTALLER_VOLUME)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_VOLUME' variable should not be defined")
    endif()
  endif()

  if(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
    message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should be defined")
  elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_PROGRAM})
    message(FATAL_ERROR "The installer program should exist at '${QT_ONLINE_INSTALLER_PROGRAM}'")
  endif()

  _detach_qt_online_installer()

  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    if(DEFINED QT_ONLINE_INSTALLER_VOLUME)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_VOLUME' variable should not be defined")
    elseif(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should not be defined")
    endif()
  else()
    if(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should be defined")
    endif()
  endif()
endif()

if("Execute Qt online installer" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  _download_qt_online_installer()
  if(DEFINED QT_ONLINE_INSTALLER_IMAGE)
    _attach_qt_online_installer()
  endif()

  if(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
    message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should be defined")
  elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_PROGRAM})
    message(FATAL_ERROR "The installer program should exist at '${QT_ONLINE_INSTALLER_PROGRAM}'")
  endif()

  execute_process(
    COMMAND ${QT_ONLINE_INSTALLER_PROGRAM} --version
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Should not fail to execute the installer program: ${RES}")
  endif()

  if(DEFINED QT_ONLINE_INSTALLER_VOLUME)
    _detach_qt_online_installer()
  endif()
endif()

if("Set up the latest version of Qt" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  setup_qt()

  if(NOT DEFINED QT_CMAKE_PREFIX_PATH)
    message(FATAL_ERROR "The 'QT_CMAKE_PREFIX_PATH' variable should be defined")
  elseif(NOT EXISTS ${QT_CMAKE_PREFIX_PATH})
    message(FATAL_ERROR "The CMake prefix path of the Qt framework should exist at '${QT_CMAKE_PREFIX_PATH}'")
  endif()
endif()

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
