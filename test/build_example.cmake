cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://github.com/threeal/assertion-cmake/releases/download/v1.0.0/Assertion.cmake
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 1d8ec589d6cc15772581bf77eb3873ff)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

file(
  DOWNLOAD https://threeal.github.io/git-checkout-cmake/v1.0.0 GitCheckout.cmake
  EXPECTED_MD5 3f49e8e2318773971d21adb98aa24470
)
include(GitCheckout.cmake)

section("it should build analogclock example")
  if(NOT EXISTS qtbase)
    git_checkout(
      https://github.com/qt/qtbase
      REF 6.2.4
      SPARSE_CHECKOUT examples/gui/analogclock examples/gui/rasterwindow
    )
  endif()

  section("reconfigure analogclock project")
    assert_execute_process(
      "${CMAKE_COMMAND}" -B build/analogclock --fresh
        qtbase/examples/gui/analogclock)
  endsection()

  section("build analogclock project")
    assert_execute_process("${CMAKE_COMMAND}" --build build/analogclock)
  endsection()
endsection()
