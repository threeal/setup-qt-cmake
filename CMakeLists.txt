cmake_minimum_required(VERSION 3.19)

project(
  SetupQt
  VERSION 0.0.0
  DESCRIPTION "Setup Qt from your CMake project"
  HOMEPAGE_URL https://github.com/threeal/setup-qt-cmake
  LANGUAGES NONE
)

if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  set(SUBPROJECT TRUE)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
if(SUBPROJECT)
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif()

if(NOT SUBPROJECT)
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
