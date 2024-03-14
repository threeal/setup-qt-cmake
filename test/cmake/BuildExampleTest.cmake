# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

set(TEST_COUNT 0)

if("Build analogclock example" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  if(NOT EXISTS qtbase)
    message(STATUS "Cloning analogclock project")
    execute_process(
      COMMAND git clone --filter=blob:none --no-checkout https://github.com/qt/qtbase
      RESULT_VARIABLE RES
    )
    if(NOT RES EQUAL 0)
      message(FATAL_ERROR "Failed to clone analogclock project")
    endif()
  endif()

  message(STATUS "Checking out analogclock project")
  execute_process(
    COMMAND git -C qtbase sparse-checkout set --cone
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to check out analogclock project")
  endif()
  execute_process(
    COMMAND git -C qtbase checkout 6.2.4
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to check out analogclock project")
  endif()
  execute_process(
    COMMAND git -C qtbase sparse-checkout set examples/gui/analogclock examples/gui/rasterwindow
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to check out analogclock project")
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
