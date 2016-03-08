##
# CMake Modules - libuv External Project
# Copyright (C) 2015 Michael Fero
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

##
# Include CMake modules
##
INCLUDE(ExternalProject)

##
# libuv related CMake options
##
OPTION(LIBUV_VERSION "libuv version")
IF(NOT LIBUV_VERSION)
  SET(LIBUV_VERSION master CACHE STRING "libuv version" FORCE)
  SET(LIBUV_ARCHIVE_NAME ${LIBUV_VERSION} CACHE STRING "libuv archive name" FORCE)
ELSE(NOT LIBUV_VERSION)
  SET(LIBUV_ARCHIVE_NAME v${LIBUV_VERSION} CACHE STRING "libuv archive name" FORCE)
ENDIF(NOT LIBUV_VERSION)
OPTION(INSTALL_PREFIX, "libuv installation prefix location")
IF(NOT INSTALL_PREFIX)
  SET(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/libs CACHE STRING "libuv install prefix" FORCE)
ENDIF(NOT INSTALL_PREFIX)
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING "CMake build type" FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

##
# libuv related CMake variables
##
SET(LIBUV_LIBRARY_NAME "libuv-library")
SET(LIBUV_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/libuv)
SET(LIBUV_ARCHIVE_URL_PREFIX "https://github.com/libuv/libuv/archive/")
SET(LIBUV_ARCHIVE_URL_SUFFIX ".tar.gz")
SET(LIBUV_ARCHIVE_URL "${LIBUV_ARCHIVE_URL_PREFIX}${LIBUV_ARCHIVE_NAME}${LIBUV_ARCHIVE_URL_SUFFIX}")

##
# Ensure dependencies are met
##
IF(WIN32)
  # Make sure Visual Studio is available
  IF(NOT MSVC)
    MESSAGE(FATAL_ERROR "Visual Studio is required to build libuv")
  ENDIF(NOT MSVC)

  # Python is required to create solution files for libuv build
  FIND_PACKAGE(PythonInterp REQUIRED)
  GET_FILENAME_COMPONENT(PYTHON_PATH ${PYTHON_EXECUTABLE} PATH)
  FILE(TO_NATIVE_PATH ${PYTHON_PATH} PYTHON_PATH)

  # Make sure the environmental configure script is available
  INCLUDE(Windows-MSVC-EnvironmentScript)
  IF(NOT VCVARSALL_SCRIPT)
    MESSAGE(FATAL_ERROR "Visual Studio environment script is required to build libuv")
  ENDIF(NOT VCVARSALL_SCRIPT)
ENDIF(WIN32)

##
# Information messages about the configuration
##
SET(LIBUV_VERSION_DISPLAY v${LIBUV_VERSION})
IF(LIBUV_VERSION MATCHES master)
  SET(LIBUV_VERSION_DISPLAY master)
ENDIF(LIBUV_VERSION MATCHES master)
MESSAGE(STATUS "libuv: ${LIBUV_VERSION_DISPLAY} [${CMAKE_BUILD_TYPE}]")

##
# Determine library suffix
##
IF(WIN32)
  SET(LIBUV_LIBRARY_SUFFIX lib)
ELSE(WIN32)
  IF(NOT BUILD_SHARED_LIBS)
    SET(LIBUV_LIBRARY_SUFFIX a)
  ELSE(NOT BUILD_SHARED_LIBS)
    SET(LIBUV_LIBRARY_SUFFIX so)
  ENDIF(NOT BUILD_SHARED_LIBS)
ENDIF(WIN32)

##
# libuv library configuration variables
##
SET(LIBUV_INSTALL_DIR ${INSTALL_PREFIX}/libuv)
IF(BUILD_SHARED_LIBS)
  SET(LIBUV_BINARY_DIR ${LIBUV_INSTALL_DIR}/bin)
ENDIF(BUILD_SHARED_LIBS)
SET(LIBUV_INCLUDE_DIR ${LIBUV_INSTALL_DIR}/include)
SET(LIBUV_LIBRARY_DIR ${LIBUV_INSTALL_DIR}/lib)
SET(LIBUV_LIBRARY libuv)
SET(LIBUV_LIBRARIES ${LIBUV_LIBRARY_DIR}/${LIBUV_LIBRARY}.${LIBUV_LIBRARY_SUFFIX})
IF(WIN32)
  SET(LIBUV_LIBRARIES ${LIBUV_LIBRARIES}
    ws2_32
    psapi
    Iphlpapi)
  IF(LIBUV_VERSION VERSION_GREATER "1.6.0" OR LIBUV_VERSION VERSION_EQUAL "1.6.0" OR LIBUV_VERSION MATCHES "master")
    SET(LIBUV_LIBRARIES ${LIBUV_LIBRARIES}
      userenv)
  ENDIF(LIBUV_VERSION VERSION_GREATER "1.6.0" OR LIBUV_VERSION VERSION_EQUAL "1.6.0" OR LIBUV_VERSION MATCHES "master")
ELSE(WIN32)
  SET(LIBUV_LIBRARIES ${LIBUV_LIBRARIES}
    pthread)
ENDIF(WIN32)

# Create build options for the platform build scripts
IF(BUILD_SHARED_LIBS)
  IF(WIN32)
    SET(LIBUV_LIBRARY_TYPE_ARGUMENT "shared")
  ELSE(WIN32)
    SET(LIBUV_LIBRARY_TYPE_ARGUMENT "shared")
  ENDIF(WIN32)
ELSE(BUILD_SHARED_LIBS)
  IF(WIN32)
    SET(LIBUV_LIBRARY_TYPE_ARGUMENT "static")
  ELSE(WIN32)
    SET(LIBUV_LIBRARY_TYPE_ARGUMENT "static")
  ENDIF(WIN32)
ENDIF(BUILD_SHARED_LIBS)

# Create configure, build and make commands for supported platforms
IF(WIN32)
# Determine if debug or release configuration should be used
  IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
    SET(LIBUV_BUILD_TYPE_ARGUMENT "debug")
  ELSE(CMAKE_BUILD_TYPE MATCHES DEBUG)
    SET(LIBUV_BUILD_TYPE_ARGUMENT "release")
  ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)

  # Determine which architecture to build libuv
  IF(VCVARSALL_ARCHITECTURE STREQUAL "x86")
    SET(LIBUV_TARGET_ARCH "x86")
  ELSE(VCVARSALL_ARCHITECTURE STREQUAL "x86")
    SET(LIBUV_TARGET_ARCH "x64")
  ENDIF(VCVARSALL_ARCHITECTURE STREQUAL "x86")

  # Create the configure script
  SET(LIBUV_CONFIGURE_SCRIPT ${LIBUV_PROJECT_PREFIX}/scripts/libuv_configure.bat)
  FILE(REMOVE ${LIBUV_CONFIGURE_SCRIPT})
  FILE(WRITE ${LIBUV_CONFIGURE_SCRIPT} "@REM Generated configure script for libuv\r\n")
  FILE(APPEND ${LIBUV_CONFIGURE_SCRIPT} "@ECHO OFF\r\n")
  FILE(APPEND ${LIBUV_CONFIGURE_SCRIPT} "IF NOT EXIST build\\gyp git clone --depth 1 --single-branch https://chromium.googlesource.com/external/gyp.git build\\gyp\r\n")
  FILE(APPEND ${LIBUV_CONFIGURE_SCRIPT} "EXIT /B\r\n")
  SET(LIBUV_CONFIGURE_COMMAND ${LIBUV_CONFIGURE_SCRIPT})

  # Create the make script
  SET(LIBUV_MAKE_SCRIPT ${LIBUV_PROJECT_PREFIX}/scripts/libuv_make.bat)
  FILE(REMOVE ${LIBUV_MAKE_SCRIPT})
  FILE(WRITE ${LIBUV_MAKE_SCRIPT} "@REM Generated make script for libuv\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "@ECHO OFF\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "SETLOCAL ENABLEDELAYEDEXPANSION\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "CALL \"${VCVARSALL_SCRIPT}\" ${VCVARSALL_ARCHITECTURE}\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "TYPE vcbuild.bat | FINDSTR /V /C:\"if defined WindowsSDKDir goto select-target\" | FINDSTR /V /C:\"if defined VCINSTALLDIR goto select-target\" > vcbuild-modified.bat\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "SET PATH=${PYTHON_PATH};%PATH%\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "CALL vcbuild-modified.bat ${LIBUV_BUILD_TYPE_ARGUMENT} ${LIBUV_TARGET_ARCH} ${LIBUV_LIBRARY_TYPE_ARGUMENT}\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "ENDLOCAL\r\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "EXIT /B\r\n")
  SET(LIBUV_BUILD_COMMAND ${LIBUV_MAKE_SCRIPT})

  # Create the install script
  SET(LIBUV_INSTALL_SCRIPT ${LIBUV_PROJECT_PREFIX}/scripts/libuv_install.bat)
  FILE(REMOVE ${LIBUV_INSTALL_SCRIPT})
  FILE(WRITE ${LIBUV_INSTALL_SCRIPT} "@REM Generated install script for libuv\r\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "@ECHO OFF\r\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "MKDIR \"${LIBUV_INCLUDE_DIR}\"\r\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "MKDIR \"${LIBUV_LIBRARY_DIR}\"\r\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "XCOPY /E /Y /Q include \"${LIBUV_INCLUDE_DIR}\"\r\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "XCOPY /E /Y /Q ${CMAKE_BUILD_TYPE}\\lib \"${LIBUV_LIBRARY_DIR}\"\r\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "EXIT /B\r\n")
  SET(LIBUV_INSTALL_COMMAND ${LIBUV_INSTALL_SCRIPT})
ELSEIF(UNIX)
  # Create the configure script (version dependent)
  SET(LIBUV_CONFIGURE_SCRIPT "${LIBUV_PROJECT_PREFIX}/scripts/configure_libuv.sh")
  FILE(REMOVE ${LIBUV_CONFIGURE_SCRIPT})
  FILE(WRITE ${LIBUV_CONFIGURE_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${LIBUV_CONFIGURE_SCRIPT} "# Generated configure script for libuv\n")
  IF(LIBUV_VERSION VERSION_EQUAL "1.0.0" OR LIBUV_VERSION VERSION_GREATER "1.0.0" OR LIBUV_VERSION MATCHES "master")
    FILE(APPEND ${LIBUV_CONFIGURE_SCRIPT} "sh autogen.sh \n")
    FILE(APPEND ${LIBUV_CONFIGURE_SCRIPT} "./configure --silent --prefix=${LIBUV_INSTALL_DIR}\n")
  ENDIF(LIBUV_VERSION VERSION_EQUAL "1.0.0" OR LIBUV_VERSION VERSION_GREATER "1.0.0" OR LIBUV_VERSION MATCHES "master")
  SET(LIBUV_CONFIGURE_COMMAND sh "${LIBUV_CONFIGURE_SCRIPT}")

  # Create the make script
  SET(LIBUV_MAKE_SCRIPT "${LIBUV_PROJECT_PREFIX}/scripts/make_libuv.sh")
  FILE(REMOVE ${LIBUV_MAKE_SCRIPT})
  FILE(WRITE ${LIBUV_MAKE_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "# Generated make script for libuv\n")
  FILE(APPEND ${LIBUV_MAKE_SCRIPT} "make\n")
  SET(LIBUV_BUILD_COMMAND sh "${LIBUV_MAKE_SCRIPT}")

  # Create the install script (version dependent)
  SET(LIBUV_INSTALL_SCRIPT "${LIBUV_PROJECT_PREFIX}/scripts/install_libuv.sh")
  FILE(REMOVE ${LIBUV_INSTALL_SCRIPT})
  FILE(WRITE ${LIBUV_INSTALL_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "# Generated install script for libuv\n")
  IF(LIBUV_VERSION VERSION_EQUAL "1.0.0" OR LIBUV_VERSION VERSION_GREATER "1.0.0" OR LIBUV_VERSION MATCHES "master")
    FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "make install\n")
  ELSE(LIBUV_VERSION VERSION_EQUAL "1.0.0" OR LIBUV_VERSION VERSION_GREATER "1.0.0")
    FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "mkdir -p ${LIBUV_LIBRARY_DIR}\n")
    FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "cp libuv* ${LIBUV_LIBRARY_DIR}\n")
    FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "cp -r include ${LIBUV_INSTALL_DIR}\n")
    FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "cd ${LIBUV_LIBRARY_DIR}\n")
    FILE(APPEND ${LIBUV_INSTALL_SCRIPT} "ln -s libuv.so libuv.so.0.10\n")
  ENDIF(LIBUV_VERSION VERSION_EQUAL "1.0.0" OR LIBUV_VERSION VERSION_GREATER "1.0.0" OR LIBUV_VERSION MATCHES "master")
  SET(LIBUV_INSTALL_COMMAND sh "${LIBUV_INSTALL_SCRIPT}")
ENDIF(WIN32)

# Determine if libuv has already been found/included
IF(NOT LIBUV_FOUND)
  # Add libuv as an external project
  EXTERNALPROJECT_ADD(${LIBUV_LIBRARY_NAME}
    PREFIX ${LIBUV_PROJECT_PREFIX}
    URL ${LIBUV_ARCHIVE_URL}
    DOWNLOAD_DIR ${LIBUV_PROJECT_PREFIX}
    CONFIGURE_COMMAND "${LIBUV_CONFIGURE_COMMAND}"
    BUILD_COMMAND "${LIBUV_BUILD_COMMAND}"
    INSTALL_COMMAND "${LIBUV_INSTALL_COMMAND}"
    BUILD_IN_SOURCE 1
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1)

  # Indicate libuv has been included
  SET(LIBUV_FOUND ON CACHE BOOL "libuv Found" FORCE)

  # Create the folder properties for the external project
  SET_TARGET_PROPERTIES(${LIBUV_LIBRARY_NAME} PROPERTIES FOLDER "external/libuv")
ENDIF(NOT LIBUV_FOUND)

##
# Update the include directory to use libuv
##
INCLUDE_DIRECTORIES(${LIBUV_INCLUDE_DIR})

##
# libuv library header files
##
SET(LIBUV_INCLUDE_FILES ${LIBUV_INCLUDE_DIR}/uv.h)
SET_SOURCE_FILES_PROPERTIES(${LIBUV_INCLUDE_FILES} PROPERTIES GENERATED TRUE)
SOURCE_GROUP("Header Files\\libuv" FILES ${LIBUV_INCLUDE_FILES})
