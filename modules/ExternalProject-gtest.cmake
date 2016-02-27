##
# CMake Modules - Google Test External Project
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
# Google test related CMake options
##
OPTION(GOOGLE_TEST_VERSION "Google test version")
IF(NOT GOOGLE_TEST_VERSION)
  SET(GOOGLE_TEST_VERSION master CACHE STRING "Google test version" FORCE)
  SET(GOOGLE_TEST_ARCHIVE_NAME master CACHE STRING "Google test archive name" FORCE)
ELSE(NOT GOOGLE_TEST_VERSION)
  SET(GOOGLE_TEST_ARCHIVE_NAME gtest-${GOOGLE_TEST_VERSION} CACHE STRING "Google test archive name" FORCE)
ENDIF(NOT GOOGLE_TEST_VERSION)
OPTION(INSTALL_PREFIX, "Google test installation prefix location")
IF(NOT INSTALL_PREFIX)
  SET(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/libs CACHE STRING "Google test install prefix" FORCE)
ENDIF(NOT INSTALL_PREFIX)

##
# Google test related CMake variables
##
SET(GOOGLE_TEST_LIBRARY_NAME google-test-library)
SET(GOOGLE_TEST_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/gtest)
IF(GOOGLE_TEST_VERSION MATCHES master)
  SET(GOOGLE_TEST_ARCHIVE_URL_PREFIX "https://github.com/svn2github/googletest/archive/")
  SET(GOOGLE_TEST_ARCHIVE_URL_SUFFIX ".tar.gz")
ELSE(GOOGLE_TEST_VERSION MATCHES master)
  SET(GOOGLE_TEST_ARCHIVE_URL_PREFIX "http://googletest.googlecode.com/files/")
  SET(GOOGLE_TEST_ARCHIVE_URL_SUFFIX ".zip")
ENDIF(GOOGLE_TEST_VERSION MATCHES master)
SET(GOOGLE_TEST_ARCHIVE_URL "${GOOGLE_TEST_ARCHIVE_URL_PREFIX}${GOOGLE_TEST_ARCHIVE_NAME}${GOOGLE_TEST_ARCHIVE_URL_SUFFIX}")

##
# Information messages about the configuration
##
SET(GOOGLE_TEST_VERSION_DISPLAY v${GOOGLE_TEST_VERSION})
IF(GOOGLE_TEST_VERSION MATCHES master)
  SET(GOOGLE_TEST_VERSION_DISPLAY master)
ENDIF(GOOGLE_TEST_VERSION MATCHES master)
MESSAGE(STATUS "Google Test: ${GOOGLE_TEST_VERSION_DISPLAY}")

##
# Determine library suffix
##
IF(WIN32)
  SET(GOOGLE_TEST_LIBRARY_SUFFIX lib)
ELSE(WIN32)
  IF(NOT BUILD_SHARED_LIBS)
    SET(GOOGLE_TEST_LIBRARY_SUFFIX a)
  ELSE(NOT BUILD_SHARED_LIBS)
    SET(GOOGLE_TEST_LIBRARY_SUFFIX so)
  ENDIF(NOT BUILD_SHARED_LIBS)
ENDIF(WIN32)

##
# Google test library configuration variables
##
SET(GOOGLE_TEST_INSTALL_DIR ${INSTALL_PREFIX}/gtest)
IF(BUILD_SHARED_LIBS)
  SET(GOOGLE_TEST_BINARY_DIR ${GOOGLE_TEST_INSTALL_DIR}/bin)
ENDIF(BUILD_SHARED_LIBS)
SET(GOOGLE_TEST_INCLUDE_DIR ${GOOGLE_TEST_INSTALL_DIR}/include)
SET(GOOGLE_TEST_LIBRARY_DIR ${GOOGLE_TEST_INSTALL_DIR}/lib/${CMAKE_CXX_LIBRARY_ARCHITECTURE})
SET(GOOGLE_TEST_LIBRARY gtest)
SET(GOOGLE_TEST_LIBRARIES ${GOOGLE_TEST_LIBRARY_DIR}/${GOOGLE_TEST_LIBRARY}.${GOOGLE_TEST_LIBRARY_SUFFIX})

# Create configure, build and make commands for supported platforms
IF(WIN32)
   # Create the install script
  SET(GOOGLE_TEST_INSTALL_SCRIPT "${GOOGLE_TEST_PROJECT_PREFIX}/scripts/install_google_test.bat")
  FILE(REMOVE ${GOOGLE_TEST_INSTALL_SCRIPT})
  FILE(WRITE ${GOOGLE_TEST_INSTALL_SCRIPT} "@REM Generated install script for Google test\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "@ECHO OFF\r\n")
  IF(BUILD_SHARED_LIBS)
    FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "MKDIR \"${GOOGLE_TEST_BINARY_DIR}\"\r\n")
  ENDIF(BUILD_SHARED_LIBS)
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "MKDIR \"${GOOGLE_TEST_INCLUDE_DIR}\"\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "MKDIR \"${GOOGLE_TEST_LIBRARY_DIR}\"\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "XCOPY /E /Y /Q include \"${GOOGLE_TEST_INCLUDE_DIR}\"\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "COPY /Y Debug\\*.lib \"${GOOGLE_TEST_LIBRARY_DIR}\"\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "COPY /Y Release\\*.lib \"${GOOGLE_TEST_LIBRARY_DIR}\"\r\n")
  IF(BUILD_SHARED_LIBS)
    FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "COPY /Y Debug\\*.dll \"${GOOGLE_TEST_BINARY_DIR}\"\r\n")
    FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "COPY /Y Release\\*.dll \"${GOOGLE_TEST_BINARY_DIR}\"\r\n")
  ENDIF(BUILD_SHARED_LIBS)
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "RMDIR /S /Q Debug\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "RMDIR /S /Q Release\r\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "EXIT /B\r\n")
  SET(GOOGLE_TEST_INSTALL_COMMAND "${GOOGLE_TEST_INSTALL_SCRIPT}")
ELSEIF(UNIX)
  # Create the install script
  SET(GOOGLE_TEST_INSTALL_SCRIPT "${GOOGLE_TEST_PROJECT_PREFIX}/scripts/install_google_test.sh")
  FILE(REMOVE ${GOOGLE_TEST_INSTALL_SCRIPT})
  FILE(WRITE ${GOOGLE_TEST_INSTALL_SCRIPT} "#!/bin/bash\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "# Generated install script for Google test\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "mkdir -p \"${GOOGLE_TEST_LIBRARY_DIR}\"\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "cp -r include \"${GOOGLE_TEST_INCLUDE_DIR}\"\n")
  FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "cp *.a \"${GOOGLE_TEST_LIBRARY_DIR}\"\n")
  IF(BUILD_SHARED_LIBS)
    FILE(APPEND ${GOOGLE_TEST_INSTALL_SCRIPT} "cp *.so \"${GOOGLE_TEST_LIBRARY_DIR}\"\n")
  ENDIF(BUILD_SHARED_LIBS)
  SET(GOOGLE_TEST_INSTALL_COMMAND sh "${GOOGLE_TEST_INSTALL_SCRIPT}")
ENDIF(WIN32)

# Determine if Google test has already been found/included
IF(NOT GOOGLE_TEST_FOUND)
 # Add Google test as an external project
  EXTERNALPROJECT_ADD(${GOOGLE_TEST_LIBRARY_NAME}
    PREFIX ${GOOGLE_TEST_PROJECT_PREFIX}
    URL ${GOOGLE_TEST_ARCHIVE_URL}
    DOWNLOAD_DIR ${GOOGLE_TEST_PROJECT_PREFIX}
    INSTALL_DIR ${GOOGLE_TEST_INSTALL_DIR}
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${GOOGLE_TEST_INSTALL_DIR}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -Dgtest_force_shared_crt=ON
      -Dgtest_build_tests=OFF
      -Dgtest_build_samples=OFF
      -Dgtest_disable_pthreads=OFF
    INSTALL_COMMAND "${GOOGLE_TEST_INSTALL_COMMAND}"
    BUILD_IN_SOURCE 1
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1)

  # Retrieve the property for include files
  EXTERNALPROJECT_GET_PROPERTY(${GOOGLE_TEST_LIBRARY_NAME} SOURCE_DIR)
  SET(GOOGLE_TEST_INCLUDE_DIR ${SOURCE_DIR}/include)

  # Indicate Google test has been included
  SET(GOOGLE_TEST_FOUND ON CACHE BOOL "Google Test Found" FORCE)

  # Create the folder properties for the external project
  SET_TARGET_PROPERTIES(${GOOGLE_TEST_LIBRARY_NAME} PROPERTIES FOLDER "external/gtest")
ENDIF(NOT GOOGLE_TEST_FOUND)

##
# Update the include directory to use Google test
##
INCLUDE_DIRECTORIES(${GOOGLE_TEST_INCLUDE_DIR})

##
# Google test library header files
##
SET(GOOGLE_TEST_INCLUDE_FILES ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-death-test.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-message.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-param-test.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-printers.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-spi.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-test-part.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest-typed-test.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest_pred_impl.h
  ${GOOGLE_TEST_INCLUDE_DIR}/gtest/gtest_prod.h)
SET_SOURCE_FILES_PROPERTIES(${GOOGLE_TEST_INCLUDE_FILES} PROPERTIES GENERATED TRUE)
SOURCE_GROUP("Header Files\\gtest" FILES ${GOOGLE_TEST_INCLUDE_FILES})
