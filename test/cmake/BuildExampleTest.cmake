# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

set(TEST_COUNT 0)

include(SetupQt)

file(
  DOWNLOAD https://threeal.github.io/git-checkout-cmake/v1.0.0 GitCheckout.cmake
  EXPECTED_MD5 3f49e8e2318773971d21adb98aa24470
)
include(GitCheckout.cmake)

if("Build rasterwindow example" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  setup_qt()

  if(NOT EXISTS qtbase)
    git_checkout(
      https://github.com/qt/qtbase
      REF 6.5.3
      SPARSE_CHECKOUT examples/gui/rasterwindow
    )
  endif()

  message(STATUS "Reconfiguring rasterwindow project")
  execute_process(
    COMMAND ${CMAKE_COMMAND}
      -B build/rasterwindow
      -D CMAKE_PREFIX_PATH=${QT_CMAKE_PREFIX_PATH}
      --fresh
      qtbase/examples/gui/rasterwindow
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to reconfigure rasterwindow project")
  endif()

  message(STATUS "Building rasterwindow project")
  execute_process(
    COMMAND ${CMAKE_COMMAND} --build build/rasterwindow
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to build rasterwindow project")
  endif()
endif()

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
