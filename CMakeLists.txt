cmake_minimum_required(VERSION 3.21)

project(
  SetupQt
  VERSION 0.0.0
  DESCRIPTION "Setup Qt from your CMake project"
  HOMEPAGE_URL https://github.com/threeal/setup-qt-cmake
  LANGUAGES NONE
)

option(SETUP_QT_ENABLE_TESTS "Enable test targets.")
option(SETUP_QT_ENABLE_INSTALL "Enable install targets."
  "${PROJECT_IS_TOP_LEVEL}")

include(cmake/SetupQt.cmake)

if(SETUP_QT_ENABLE_TESTS)
  enable_testing()

  file(
    DOWNLOAD https://github.com/threeal/assertion-cmake/releases/download/v1.0.0/Assertion.cmake
      ${CMAKE_BINARY_DIR}/Assertion.cmake
    EXPECTED_MD5 1d8ec589d6cc15772581bf77eb3873ff)
  include(${CMAKE_BINARY_DIR}/Assertion.cmake)

  assertion_add_test(test/build_example.cmake)
  assertion_add_test(test/setup_qt.cmake)
endif()

if(SETUP_QT_ENABLE_INSTALL)
  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
    SetupQtConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
  )

  install(
    FILES
      cmake/SetupQt.cmake
      cmake/SetupQtConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/SetupQtConfigVersion.cmake
    DESTINATION lib/cmake/SetupQt
  )
endif()
