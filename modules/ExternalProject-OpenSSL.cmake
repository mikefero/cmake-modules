##
# CMake Modules - OpenSSL External Project
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
# OpenSSL related CMake options
##
OPTION(OPENSSL_VERSION "OpenSSL version")
IF(NOT OPENSSL_VERSION)
  SET(OPENSSL_VERSION master CACHE STRING "OpenSSL version" FORCE)
  SET(OPENSSL_ARCHIVE_VERSION master CACHE STRING "OpenSSL archive version" FORCE)
  SET(OPENSSL_ARCHIVE_NAME ${OPENSSL_ARCHIVE_VERSION} CACHE STRING "OpenSSL archive name" FORCE)
ELSE(NOT OPENSSL_VERSION)
  STRING(REPLACE "." "_" OPENSSL_ARCHIVE_VERSION ${OPENSSL_VERSION})
  SET(OPENSSL_ARCHIVE_NAME OpenSSL_${OPENSSL_ARCHIVE_VERSION} CACHE STRING "OpenSSL archive name" FORCE)
ENDIF(NOT OPENSSL_VERSION)
OPTION(WITH_ZLIB "Build with zlib support" OFF)
IF(WITH_ZLIB)
  INCLUDE(ExternalProject-zlib)
ENDIF(WITH_ZLIB)
OPTION(INSTALL_PREIX, "OpenSSL installation prefix location")
IF(NOT INSTALL_PREFIX)
  SET(INSTALL_PREFIX "${CMAKE_BINARY_DIR}/libs" CACHE STRING "OpenSSL install prefix" FORCE)
ENDIF(NOT INSTALL_PREFIX)
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING "CMake build type" FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

##
# OpenSSL related CMake variables
##
SET(OPENSSL_LIBRARY_NAME "openssl-library")
SET(OPENSSL_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/openssl)
SET(OPENSSL_ARCHIVE_URL_PREFIX "https://github.com/openssl/openssl/archive/")
SET(OPENSSL_ARCHIVE_URL_SUFFIX ".tar.gz")
SET(OPENSSL_ARCHIVE_URL "${OPENSSL_ARCHIVE_URL_PREFIX}${OPENSSL_ARCHIVE_NAME}${OPENSSL_ARCHIVE_URL_SUFFIX}")

##
# Ensure dependencies are met
##
IF(WIN32)
  # Make sure Visual Studio is available
  IF(NOT MSVC)
    MESSAGE(FATAL_ERROR "Visual Studio is required to build OpenSSL")
  ENDIF(NOT MSVC)

  # Perl is required to create NMake files for OpenSSL build
  FIND_PACKAGE(Perl REQUIRED)
  IF(PERL_EXECUTABLE MATCHES ${CYGWIN_INSTALL_PATH})
    MESSAGE(FATAL_ERROR "Cygwin Perl Executable Found: Please install ActiveState Perl [http://www.activestate.com/activeperl/downloads]")
  ENDIF(PERL_EXECUTABLE MATCHES ${CYGWIN_INSTALL_PATH})
  GET_FILENAME_COMPONENT(PERL_PATH ${PERL_EXECUTABLE} PATH)
  FILE(TO_NATIVE_PATH ${PERL_PATH} PERL_PATH)

  # Make sure the environmental configure script is available
  INCLUDE(Windows-MSVC-EnvironmentScript)
  IF(NOT VCVARSALL_SCRIPT)
    MESSAGE(FATAL_ERROR "Visual Studio environment script is required to build OpenSSL")
  ENDIF(NOT VCVARSALL_SCRIPT)
ENDIF(WIN32)

##
# Information messages about the configuration
##
SET(OPENSSL_VERSION_DISPLAY v${OPENSSL_VERSION})
IF(OPENSSL_VERSION MATCHES master)
  SET(OPENSSL_VERSION_DISPLAY ${OPENSSL_VERSION})
ENDIF(OPENSSL_VERSION MATCHES master)
MESSAGE(STATUS "OpenSSL: ${OPENSSL_VERSION_DISPLAY} [${CMAKE_BUILD_TYPE}]")

##
# Determine library suffix
##
IF(WIN32)
  SET(OPENSSL_LIBRARY_SUFFIX lib)
ELSE(WIN32)
  IF(NOT BUILD_SHARED_LIBS)
    SET(OPENSSL_LIBRARY_SUFFIX a)
  ELSE(NOT BUILD_SHARED_LIBS)
    SET(OPENSSL_LIBRARY_SUFFIX so)
  ENDIF(NOT BUILD_SHARED_LIBS)
ENDIF(WIN32)

##
# OpenSSL library configuration variables
##
SET(OPENSSL_INSTALL_DIR "${INSTALL_PREFIX}/openssl")
SET(OPENSSL_BINARY_DIR "${OPENSSL_INSTALL_DIR}/bin")
SET(OPENSSL_INCLUDE_DIR "${OPENSSL_INSTALL_DIR}/include")
SET(OPENSSL_LIBRARY_DIR "${OPENSSL_INSTALL_DIR}/lib")
IF(WIN32)
  SET(OPENSSL_LIBEAY_LIBRARY libeay32)
  SET(OPENSSL_SSLEAY_LIBRARY ssleay32)
  SET(OPENSSL_LIBRARIES ${OPENSSL_LIBRARY_DIR}/${OPENSSL_LIBEAY_LIBRARY}.${OPENSSL_LIBRARY_SUFFIX}
    ${OPENSSL_LIBRARY_DIR}/${OPENSSL_SSLEAY_LIBRARY}.${OPENSSL_LIBRARY_SUFFIX}
    crypt32)
ELSE(WIN32)
  SET(OPENSSL_LIBSSL_LIBRARY libssl)
  SET(OPENSSL_LIBCRYPTO_LIBRARY libcrypto)
  SET(OPENSSL_LIBRARIES ${OPENSSL_LIBRARY_DIR}/${OPENSSL_LIBSSL_LIBRARY}.${OPENSSL_LIBRARY_SUFFIX}
    ${OPENSSL_LIBRARY_DIR}/${OPENSSL_LIBCRYPTO_LIBRARY}.${OPENSSL_LIBRARY_SUFFIX}
    dl)
ENDIF(WIN32)

# Create build options for the platform build scripts
IF(BUILD_SHARED_LIBS)
  IF(WITH_ZLIB)
    SET(OPENSSL_ZLIB_CONFIGURE_ARGUMENT "zlib-dynamic")
    SET(ZLIB_LIB ${ZLIB_SHARED_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
    IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
      SET(ZLIB_LIB ${ZLIB_SHARED_DEBUG_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
    ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)
  ENDIF(WITH_ZLIB)
ELSE(BUILD_SHARED_LIBS)
  SET(OPENSSL_BUILD_TYPE_ARGUMENT "enable-static-engine no-shared")
  IF(WITH_ZLIB)
      SET(OPENSSL_ZLIB_CONFIGURE_ARGUMENT "no-zlib-dynamic")
      SET(ZLIB_LIB ${ZLIB_STATIC_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
      IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
        SET(ZLIB_LIB ${ZLIB_STATIC_DEBUG_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
      ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)
    ENDIF(WITH_ZLIB)
ENDIF(BUILD_SHARED_LIBS)

# Create configure, build and make commands for supported platforms
IF(WIN32)
  # Determine which compiler to use for configuration script
  IF(CMAKE_CL_64)
    SET(OPENSSL_CONFIGURE_COMPILER "VC-WIN64A")
    SET(OPENSSL_CONFIGURE_MAKEFILE_SCRIPT "ms\\do_win64a.bat")
  ELSE(CMAKE_CL_64)
    SET(OPENSSL_CONFIGURE_COMPILER "VC-WIN32 no-asm")
    SET(OPENSSL_CONFIGURE_MAKEFILE_SCRIPT "ms\\do_ms.bat")
  ENDIF(CMAKE_CL_64)

  # Determine if debug configuration should be used and default ignore libs
  IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
    SET(OPENSSL_CONFIGURE_COMPILER "debug-${OPENSSL_CONFIGURE_COMPILER}")
    SET(OPENSSL_MAKE_LFLAGS "/NODEFAULTLIB:MSVCRTD.LIB")
  ELSE(CMAKE_BUILD_TYPE MATCHES DEBUG)
    SET(OPENSSL_MAKE_LFLAGS "/NODEFAULTLIB:MSVCRT.LIB")
  ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)

  # Create an updated installation prefix for a batch script
  FILE(TO_NATIVE_PATH ${OPENSSL_INSTALL_DIR} OPENSSL_INSTALL_DIR)

  # Determine if shared or static library should be built
  IF(BUILD_SHARED_LIBS)
    SET(OPENSSL_MAKEFILE "ms\\ntdll.mak")
  ELSE(BUILD_SHARED_LIBS)
    SET(OPENSSL_MAKEFILE "ms\\nt.mak")
  ENDIF(BUILD_SHARED_LIBS)

  # Create the configure script
  SET(OPENSSL_CONFIGURE_SCRIPT "${OPENSSL_PROJECT_PREFIX}/scripts/configure_openssl.bat")
  FILE(REMOVE ${OPENSSL_CONFIGURE_SCRIPT})
  FILE(WRITE ${OPENSSL_CONFIGURE_SCRIPT} "@REM Generated configure script for OpenSSL\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "@ECHO OFF\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "SETLOCAL ENABLEDELAYEDEXPANSION\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "CALL \"${VCVARSALL_SCRIPT}\" ${VCVARSALL_ARCHITECTURE}\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "SET PATH=${PERL_PATH};%PATH%\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "CALL :SHORTENPATH \"${OPENSSL_INSTALL_DIR}\" SHORTENED_OPENSSL_INSTALL_DIR\r\n")
  IF(WITH_ZLIB)
    FILE(TO_NATIVE_PATH ${ZLIB_INCLUDE_DIR} ZLIB_INCLUDE_DIR)
    FILE(TO_NATIVE_PATH ${ZLIB_LIBRARY_DIR} ZLIB_LIBRARY_DIR)
    FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "CALL :SHORTENPATH \"${ZLIB_INCLUDE_DIR}\" SHORTENED_ZLIB_INCLUDE_DIR\r\n")
    FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "CALL :SHORTENPATH \"${ZLIB_LIBRARY_DIR}\" SHORTENED_ZLIB_LIBRARY_DIR\r\n")
    SET(OPENSSL_WITH_ZLIB_ARGUMENT "zlib ${OPENSSL_ZLIB_CONFIGURE_ARGUMENT} --with-zlib-include=!SHORTENED_ZLIB_INCLUDE_DIR! --with-zlib-lib=!SHORTENED_ZLIB_LIBRARY_DIR!\\${ZLIB_LIB}")
  ENDIF(WITH_ZLIB)
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "perl Configure ${OPENSSL_BUILD_TYPE_ARGUMENT} ${OPENSSL_WITH_ZLIB_ARGUMENT} --openssldir=!SHORTENED_OPENSSL_INSTALL_DIR! --prefix=!SHORTENED_OPENSSL_INSTALL_DIR! ${OPENSSL_CONFIGURE_COMPILER}\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "CALL ${OPENSSL_CONFIGURE_MAKEFILE_SCRIPT}\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "ENDLOCAL\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "EXIT /B\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} ":SHORTENPATH\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "  FOR %%A IN (\"%~1\") DO SET %~2=%%~SA\r\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "  EXIT /B\r\n")
  SET(OPENSSL_CONFIGURE_COMMAND "${OPENSSL_CONFIGURE_SCRIPT}")

  # Create the make script
  SET(OPENSSL_MAKE_SCRIPT "${OPENSSL_PROJECT_PREFIX}/scripts/make_openssl.bat")
  FILE(REMOVE ${OPENSSL_MAKE_SCRIPT})
  FILE(WRITE ${OPENSSL_MAKE_SCRIPT} "@REM Generated make script for OpenSSL\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "@ECHO OFF\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "SETLOCAL ENABLEDELAYEDEXPANSION\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "CALL \"${VCVARSALL_SCRIPT}\" ${VCVARSALL_ARCHITECTURE}\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "NMake /F \"${OPENSSL_MAKEFILE}\" LFLAGS=\"${OPENSSL_MAKE_LFLAGS}\"\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "ENDLOCAL\r\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "EXIT /B\r\n")
  SET(OPENSSL_BUILD_COMMAND "${OPENSSL_MAKE_SCRIPT}")

  # Create the install script
  SET(OPENSSL_INSTALL_SCRIPT "${OPENSSL_PROJECT_PREFIX}/scripts/install_openssl.bat")
  FILE(REMOVE ${OPENSSL_INSTALL_SCRIPT})
  FILE(WRITE ${OPENSSL_INSTALL_SCRIPT} "@REM Generated install script for OpenSSL\r\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "@ECHO OFF\r\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "SETLOCAL ENABLEDELAYEDEXPANSION\r\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "CALL \"${VCVARSALL_SCRIPT}\" ${VCVARSALL_ARCHITECTURE}\r\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "NMake /F \"${OPENSSL_MAKEFILE}\" install\r\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "IF NOT %ERRORLEVEL% EQU 0 EXIT /B 1\r\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "EXIT /B\r\n")
  SET(OPENSSL_INSTALL_COMMAND "${OPENSSL_INSTALL_SCRIPT}")
ELSEIF(UNIX)
  # Create the configure script
  SET(OPENSSL_CONFIGURE_SCRIPT "${OPENSSL_PROJECT_PREFIX}/scripts/configure_openssl.sh")
  FILE(REMOVE ${OPENSSL_CONFIGURE_SCRIPT})
  FILE(WRITE ${OPENSSL_CONFIGURE_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "# Generated configure script for OpenSSL\n")
  IF(WITH_ZLIB)
    SET(OPENSSL_WITH_ZLIB_ARGUMENT "zlib ${OPENSSL_ZLIB_CONFIGURE_ARGUMENT} --with-zlib-include=${ZLIB_INCLUDE_DIR} --with-zlib-lib=${ZLIB_LIBRARY_DIR}/${ZLIB_LIB}")
  ENDIF(WITH_ZLIB)
  FILE(APPEND ${OPENSSL_CONFIGURE_SCRIPT} "./config ${OPENSSL_BUILD_TYPE_ARGUMENT} ${OPENSSL_WITH_ZLIB_ARGUMENT} --openssldir=${OPENSSL_INSTALL_DIR} --prefix=${OPENSSL_INSTALL_DIR}\n")
  SET(OPENSSL_CONFIGURE_COMMAND sh "${OPENSSL_CONFIGURE_SCRIPT}")

  # Create the make script
  SET(OPENSSL_MAKE_SCRIPT "${OPENSSL_PROJECT_PREFIX}/scripts/make_openssl.sh")
  FILE(REMOVE ${OPENSSL_MAKE_SCRIPT})
  FILE(WRITE ${OPENSSL_MAKE_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "# Generated make script for OpenSSL\n")
  FILE(APPEND ${OPENSSL_MAKE_SCRIPT} "make\n")
  SET(OPENSSL_BUILD_COMMAND sh "${OPENSSL_MAKE_SCRIPT}")

  # Create the install script
  SET(OPENSSL_INSTALL_SCRIPT "${OPENSSL_PROJECT_PREFIX}/scripts/install_openssl.sh")
  FILE(REMOVE ${OPENSSL_INSTALL_SCRIPT})
  FILE(WRITE ${OPENSSL_INSTALL_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "# Generated install script for OpenSSL\n")
  FILE(APPEND ${OPENSSL_INSTALL_SCRIPT} "make install\n")
  SET(OPENSSL_INSTALL_COMMAND sh "${OPENSSL_INSTALL_SCRIPT}")
ENDIF(WIN32)

# Determine if OpenSSL has already been found/included
IF(NOT OPENSSL_FOUND)
  # Add OpenSSL as an external project
  EXTERNALPROJECT_ADD(${OPENSSL_LIBRARY_NAME}
    PREFIX ${OPENSSL_PROJECT_PREFIX}
    URL ${OPENSSL_ARCHIVE_URL}
    DOWNLOAD_DIR ${OPENSSL_PROJECT_PREFIX}
    CONFIGURE_COMMAND "${OPENSSL_CONFIGURE_COMMAND}"
    BUILD_COMMAND "${OPENSSL_BUILD_COMMAND}"
    INSTALL_COMMAND "${OPENSSL_INSTALL_COMMAND}"
    BUILD_IN_SOURCE 1
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1)

  # Indicate OpenSSL has been included
  SET(OPENSSL_FOUND ON CACHE BOOL "OpenSSL Found" FORCE)

  # Create the folder properties for the external project
  SET_TARGET_PROPERTIES(${OPENSSL_LIBRARY_NAME} PROPERTIES FOLDER "external/OpenSSL")
ENDIF(NOT OPENSSL_FOUND)

# Determine if zlib should be added as a dependency
IF(WITH_ZLIB)
  ADD_DEPENDENCIES(${OPENSSL_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME})
ENDIF(WITH_ZLIB)

##
# Update the include directory to use libssh2
##
INCLUDE_DIRECTORIES(${OPENSSL_INCLUDE_DIR})

##
# OpenSSL library header files
##
SET(OPENSSL_INCLUDE_FILES ${OPENSSL_INCLUDE_DIR}/openssl/conf.h ${OPENSSL_INCLUDE_DIR}/openssl/engine.h ${OPENSSL_INCLUDE_DIR}/openssl/rand.h ${OPENSSL_INCLUDE_DIR}/openssl/ssl.h)
SET_SOURCE_FILES_PROPERTIES(${OPENSSL_INCLUDE_FILES} PROPERTIES GENERATED TRUE)
SOURCE_GROUP("Header Files\\OpenSSL" FILES ${OPENSSL_INCLUDE_FILES})
