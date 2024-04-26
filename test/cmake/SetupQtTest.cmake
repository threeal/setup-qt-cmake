# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

include(SetupQt)

set(TEST_COUNT 0)

if("Download Qt online installer" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  _download_qt_online_installer()

  if(NOT EXISTS ${QT_ONLINE_INSTALLER_PATH})
    message(FATAL_ERROR "The downloaded installer does not exist in ${QT_ONLINE_INSTALLER_PATH}")
  endif()
endif()

if("Attach and detach Qt online installer" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  _attach_qt_online_installer()

  if(APPLE)
    if(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME_PATH)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_VOLUME_PATH' variable should be defined")
    elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_VOLUME_PATH})
      message(FATAL_ERROR "The attached installer does not exist at '${QT_ONLINE_INSTALLER_VOLUME_PATH}'")
    endif()
  else()
    if(DEFINED QT_ONLINE_INSTALLER_VOLUME_PATH)
      message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_VOLUME_PATH' variable should not be defined")
    endif()
  endif()

  if(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
    message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_PROGRAM' variable should be defined")
  elseif(NOT EXISTS ${QT_ONLINE_INSTALLER_PROGRAM})
    message(FATAL_ERROR "The installer program does not exist at '${QT_ONLINE_INSTALLER_PROGRAM}'")
  endif()

  _detach_qt_online_installer()

  if(DEFINED QT_ONLINE_INSTALLER_VOLUME_PATH)
    message(FATAL_ERROR "The 'QT_ONLINE_INSTALLER_VOLUME_PATH' variable should not be defined")
  endif()
endif()

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
