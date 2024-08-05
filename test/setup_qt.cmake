find_package(SetupQt REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../cmake)

section("it should download Qt online installer")
  _download_qt_online_installer()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
    assert(DEFINED QT_ONLINE_INSTALLER_IMAGE)
    assert(EXISTS "${QT_ONLINE_INSTALLER_IMAGE}")
    assert(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  else()
    assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
    assert(EXISTS "${QT_ONLINE_INSTALLER_PROGRAM}")
    assert(NOT DEFINED QT_ONLINE_INSTALLER_IMAGE)
  endif()
endsection()

section("it should attach and detach Qt online installer")
  _download_qt_online_installer()
  _attach_qt_online_installer()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
    assert(DEFINED QT_ONLINE_INSTALLER_VOLUME)
    assert(EXISTS "${QT_ONLINE_INSTALLER_VOLUME}")
  else()
    assert(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME)
  endif()

  assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  assert(EXISTS "${QT_ONLINE_INSTALLER_PROGRAM}")

  _detach_qt_online_installer()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
    assert(NOT DEFINED QT_ONLINE_INSTALLER_VOLUME)
    assert(NOT DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  else()
    assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  endif()
endsection()

section("it should execute Qt online installer")
  _download_qt_online_installer()
  if(DEFINED QT_ONLINE_INSTALLER_IMAGE)
    _attach_qt_online_installer()
  endif()

  assert(DEFINED QT_ONLINE_INSTALLER_PROGRAM)
  assert(EXISTS "${QT_ONLINE_INSTALLER_PROGRAM}")

  assert_execute_process("${QT_ONLINE_INSTALLER_PROGRAM}" --version)

  if(DEFINED QT_ONLINE_INSTALLER_VOLUME)
    _detach_qt_online_installer()
  endif()
endsection()
