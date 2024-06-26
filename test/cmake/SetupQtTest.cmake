cmake_minimum_required(VERSION 3.5)

file(
  DOWNLOAD https://threeal.github.io/assertion-cmake/v0.2.0
    ${CMAKE_BINARY_DIR}/Assertion.cmake
  EXPECTED_MD5 4ee0e5217b07442d1a31c46e78bb5fac)
include(${CMAKE_BINARY_DIR}/Assertion.cmake)

find_package(SetupQt REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../../cmake)

function("Download Qt online installer")
  _download_qt_online_installer()

  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    assert(DEFINED QT_ONLINE_INSTALLER_IMAGE)
    assert(EXISTS "${QT_ONLINE_INSTALLER_IMAGE}")
    assert(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  else()
    assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
    assert(EXISTS "${QT_ONLINE_INSTALLER_PROGRAM}")
    assert(NOT DEFINED QT_ONLINE_INSTALLER_IMAGE)
  endif()
endfunction()

function("Attach and detach Qt online installer")
  _download_qt_online_installer()
  _attach_qt_online_installer()

  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    assert(DEFINED QT_ONLINE_INSTALLER_VOLUME)
    assert(EXISTS "${QT_ONLINE_INSTALLER_VOLUME}")
  else()
    assert(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME)
  endif()

  assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  assert(EXISTS "${QT_ONLINE_INSTALLER_PROGRAM}")

  _detach_qt_online_installer()

  if(CMAKE_SYSTEM_NAME STREQUAL Darwin)
    assert(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME)
    assert(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  else()
    assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  endif()
endfunction()

function("Execute Qt online installer")
  _download_qt_online_installer()
  if(DEFINED QT_ONLINE_INSTALLER_IMAGE)
    _attach_qt_online_installer()
  endif()

  assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  assert(EXISTS "${QT_ONLINE_INSTALLER_PROGRAM}")

  assert_execute_process(COMMAND "${QT_ONLINE_INSTALLER_PROGRAM}" --version)

  if(DEFINED QT_ONLINE_INSTALLER_VOLUME)
    _detach_qt_online_installer()
  endif()
endfunction()

cmake_language(CALL "${TEST_COMMAND}")
