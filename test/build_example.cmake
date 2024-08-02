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
