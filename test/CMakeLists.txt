add_test(
  NAME BuildExampleTest.cmake
  COMMAND "${CMAKE_COMMAND}"
    -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/BuildExampleTest.cmake)

add_test(
  NAME SetupQtTest.cmake
  COMMAND "${CMAKE_COMMAND}"
    -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/SetupQtTest.cmake)
