# Matches everything if not defined
if(NOT TEST_MATCHES)
  set(TEST_MATCHES ".*")
endif()

set(TEST_COUNT 0)

if("Build analogclock example" MATCHES ${TEST_MATCHES})
  math(EXPR TEST_COUNT "${TEST_COUNT} + 1")

  message(STATUS "Reconfiguring analogclock project")
  execute_process(
    COMMAND ${CMAKE_COMMAND}
      -B ${CMAKE_CURRENT_LIST_DIR}/build/analogclock
      --fresh
      $ENV{HOME}/Qt/Examples/Qt-6.2.4/gui/analogclock
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to reconfigure analogclock project")
  endif()

  message(STATUS "Building analogclock project")
  execute_process(
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_LIST_DIR}/build/analogclock
    RESULT_VARIABLE RES
  )
  if(NOT RES EQUAL 0)
    message(FATAL_ERROR "Failed to build analogclock project")
  endif()
endif()

if(TEST_COUNT LESS_EQUAL 0)
  message(FATAL_ERROR "Nothing to test with: ${TEST_MATCHES}")
endif()
