file(
  DOWNLOAD https://threeal.github.io/git-checkout-cmake/v1.0.0 GitCheckout.cmake
  EXPECTED_MD5 3f49e8e2318773971d21adb98aa24470
)
include(GitCheckout.cmake)

function("Build analogclock example")
  if(NOT EXISTS qtbase)
    git_checkout(
      https://github.com/qt/qtbase
      REF 6.2.4
      SPARSE_CHECKOUT examples/gui/analogclock examples/gui/rasterwindow
    )
  endif()

  message(STATUS "Reconfiguring analogclock project")
  execute_process(
    COMMAND "${CMAKE_COMMAND}"
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
    COMMAND "${CMAKE_COMMAND}" --build build/analogclock
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to build analogclock project")
  endif()
endfunction()

if(NOT DEFINED TEST_COMMAND)
  message(FATAL_ERROR "The 'TEST_COMMAND' variable should be defined")
elseif(NOT COMMAND "${TEST_COMMAND}")
  message(FATAL_ERROR "Unable to find a command named '${TEST_COMMAND}'")
endif()

cmake_language(CALL "${TEST_COMMAND}")
