function(add_cmake_test FILE)
  math(EXPR STOP "${ARGC} - 1")
  foreach(I RANGE 1 "${STOP}")
    add_test(
      NAME "${ARGV${I}}"
      COMMAND "${CMAKE_COMMAND}"
        -D "TEST_COMMAND=${ARGV${I}}"
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
