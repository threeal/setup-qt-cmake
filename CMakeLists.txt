cmake_minimum_required(VERSION 3.21)

project(
  SetupQt
  VERSION 0.0.0
  DESCRIPTION "Setup Qt from your CMake project"
  HOMEPAGE_URL https://github.com/threeal/setup-qt-cmake
  LANGUAGES NONE
)

list(PREPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
if(NOT PROJECT_IS_TOP_LEVEL)
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endif()

if(PROJECT_IS_TOP_LEVEL)
  if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
  endif()

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
