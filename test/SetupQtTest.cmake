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

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
