# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

set(TEST_COUNT 0)

file(
  DOWNLOAD https://threeal.github.io/git-checkout-cmake/v1.0.0 GitCheckout.cmake
  EXPECTED_MD5 3f49e8e2318773971d21adb98aa24470
)
include(GitCheckout.cmake)

if("Build analogclock example" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  if(NOT EXISTS qtbase)
    git_checkout(
      https://github.com/qt/qtbase
      REF 6.2.4
      SPARSE_CHECKOUT examples/gui/analogclock examples/gui/rasterwindow
    )
  endif()

  message(STATUS "Reconfiguring analogclock project")
  execute_process(
    COMMAND ${CMAKE_COMMAND}
      -B build/analogclock
      --fresh
      qtbase/examples/gui/analogclock
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to reconfigure analogclock project")
  endif()

  message(STATUS "Building analogclock project")
  execute_process(
    COMMAND ${CMAKE_COMMAND} --build build/analogclock
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to build analogclock project")
  endif()
endif()

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
