function(add_cmake_test FILE)
  foreach(NAME ${ARGN})
    add_test(
      NAME ${NAME}
      COMMAND ${CMAKE_COMMAND}
        -D CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
        -D CMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
        -D TEST_MATCHES=^${NAME}$
        -P ${CMAKE_CURRENT_SOURCE_DIR}/${FILE}
    )
  endforeach()
endfunction()

add_cmake_test(
  cmake/BuildExampleTest.cmake
  "Build analogclock example"
)

add_cmake_test(
  cmake/SetupQtTest.cmake
  "Download Qt online installer"
  "Attach and detach Qt online installer"
  "Execute Qt online installer"
)
