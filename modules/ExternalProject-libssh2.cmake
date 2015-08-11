##
# CMake Modules - libssh2 External Project
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
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.11)

##
# Include CMake modules
##
INCLUDE(ExternalProject)
INCLUDE(ExternalProject-OpenSSL)

##
# libssh2 related CMake options
##
OPTION(LIBSSH2_VERSION "libssh2 version")
IF(NOT LIBSSH2_VERSION)
  SET(LIBSSH2_VERSION master CACHE STRING "libssh2 version" FORCE)
  SET(LIBSSH2_ARCHIVE_NAME ${LIBSSH2_VERSION} CACHE STRING "libssh2 archive name" FORCE)
ELSE(NOT LIBSSH2_VERSION)
  SET(LIBSSH2_ARCHIVE_NAME libssh2-${LIBSSH2_VERSION} CACHE STRING "libssh2 archive name" FORCE)
ENDIF(NOT LIBSSH2_VERSION)
OPTION(INSTALL_PREFIX, "libssh2 installation prefix location")
IF(NOT INSTALL_PREFIX)
  SET(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/libs CACHE STRING "libssh2 install prefix" FORCE)
ENDIF(NOT INSTALL_PREFIX)
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING "CMake build type" FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

##
# libssh2 related CMake variables
##
SET(LIBSSH2_LIBRARY_NAME "libssh2-library")
SET(LIBSSH2_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/libssh2)
SET(LIBSSH2_ARCHIVE_URL_PREFIX "https://github.com/libssh2/libssh2/archive/")
SET(LIBSSH2_ARCHIVE_URL_SUFFIX ".tar.gz")
SET(LIBSSH2_ARCHIVE_URL "${LIBSSH2_ARCHIVE_URL_PREFIX}${LIBSSH2_ARCHIVE_NAME}${LIBSSH2_ARCHIVE_URL_SUFFIX}")

##
# Information messages about the configuration
##
SET(LIBSSH2_VERSION_DISPLAY v${LIBSSH2_VERSION})
IF(LIBSSH2_VERSION MATCHES master)
  SET(LIBSSH2_VERSION_DISPLAY master)
ENDIF(LIBSSH2_VERSION MATCHES master)
MESSAGE(STATUS "libssh2: ${LIBSSH2_VERSION_DISPLAY} [${CMAKE_BUILD_TYPE}]")

##
# Determine library suffix
##
IF(WIN32)
  SET(LIBSSH2_LIBRARY_SUFFIX lib)
ELSE(WIN32)
  IF(NOT BUILD_SHARED_LIBS)
    SET(LIBSSH2_LIBRARY_SUFFIX a)
  ELSE(NOT BUILD_SHARED_LIBS)
    SET(LIBSSH2_LIBRARY_SUFFIX so)
  ENDIF(NOT BUILD_SHARED_LIBS)
ENDIF(WIN32)

##
# libssh2 library configuration variables
##
SET(LIBSSH2_INSTALL_DIR ${INSTALL_PREFIX}/libssh2)
IF(BUILD_SHARED_LIBS)
  SET(LIBSSH2_BINARY_DIR ${LIBSSH2_INSTALL_DIR}/bin)
ENDIF(BUILD_SHARED_LIBS)
SET(LIBSSH2_INCLUDE_DIR ${LIBSSH2_INSTALL_DIR}/include)
SET(LIBSSH2_LIBRARY_DIR ${LIBSSH2_INSTALL_DIR}/lib/${CMAKE_CXX_LIBRARY_ARCHITECTURE})
SET(LIBSSH2_LIBRARY libssh2)
SET(LIBSSH2_LIBRARIES ${LIBSSH2_LIBRARY_DIR}/${LIBSSH2_LIBRARY}.${LIBSSH2_LIBRARY_SUFFIX})

# Determine if libssh2 has already been found/included
IF(NOT LIBSSH2_FOUND)
  # Add libssh2 as an external project (OpenSSL is a dependency)
  EXTERNALPROJECT_ADD(${LIBSSH2_LIBRARY_NAME}
    DEPENDS ${OPENSSL_LIBRARY_NAME}
    PREFIX ${LIBSSH2_PROJECT_PREFIX}
    URL ${LIBSSH2_ARCHIVE_URL}
    DOWNLOAD_DIR ${LIBSSH2_PROJECT_PREFIX}
    INSTALL_DIR ${LIBSSH2_INSTALL_DIR}
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${LIBSSH2_INSTALL_DIR}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DBUILD_EXAMPLES=OFF
      -DBUILD_TESTING=OFF
      -DOPENSSL_ROOT_DIR=${OPENSSL_INSTALL_DIR}
      -D_OPENSSL_INCLUDEDIR=${OPENSSL_INSTALL_DIR}
      -D_OPENSSL_LIBDIR=${OPENSSL_LIBRARY_DIR}
      -D_OPENSSL_VERSION=${OPENSSL_VERSION}
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1)

  # Indicate libssh2 has been included
  SET(LIBSSH2_FOUND ON CACHE BOOL "libssh2 Found" FORCE)

  # Create the folder properties for the external project
  SET_TARGET_PROPERTIES(${LIBSSH2_LIBRARY_NAME} PROPERTIES FOLDER "external/libssh2")
ENDIF(NOT LIBSSH2_FOUND)

# Determine if zlib should be added as a dependency
IF(WITH_ZLIB)
  ADD_DEPENDENCIES(${OPENSSL_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME})
ENDIF(WITH_ZLIB)

##
# Update the include directory to use libssh2
##
INCLUDE_DIRECTORIES(${LIBSSH2_INCLUDE_DIR})

##
# libssh2 library header files
##
SET(LIBSSH2_INCLUDE_FILES ${LIBSSH2_INCLUDE_DIR}/libssh2.h)
SET_SOURCE_FILES_PROPERTIES(${LIBSSH2_INCLUDE_FILES} PROPERTIES GENERATED TRUE)
SOURCE_GROUP("Header Files\\libssh2" FILES ${LIBSSH2_INCLUDE_FILES})
