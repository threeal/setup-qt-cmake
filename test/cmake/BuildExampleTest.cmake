cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://github.com/threeal/assertion-cmake/releases/download/v0.3.0/Assertion.cmake
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 851f49c10934d715df5d0b59c8b8c72a)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

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
  assert_execute_process(
    "${CMAKE_COMMAND}" -B build/analogclock --fresh
      qtbase/examples/gui/analogclock)

  message(STATUS "Building analogclock project")
  assert_execute_process("${CMAKE_COMMAND}" --build build/analogclock)
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
