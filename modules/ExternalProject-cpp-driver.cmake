##
# CMake Modules - DataStax C/C++ Driver
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
INCLUDE(ExternalProject-libuv)

##
# DataStax C/C++ driver related CMake options
##
OPTION(CPP_DRIVER_VERSION "DataStax C/C++ driver version")
IF(NOT CPP_DRIVER_VERSION)
  SET(CPP_DRIVER_VERSION master CACHE STRING "DataStax C/C++ driver version" FORCE)
  SET(CPP_DRIVER_ARCHIVE_NAME ${CPP_DRIVER_VERSION} CACHE STRING "DataStax C/C++ driver archive name" FORCE)
ELSE(NOT CPP_DRIVER_VERSION)
  SET(CPP_DRIVER_ARCHIVE_NAME ${CPP_DRIVER_VERSION} CACHE STRING "DataStax C/C++ driver archive name" FORCE)
  IF(LIBUV_VERSION)
    IF(CPP_DRIVER_VERSION VERSION_LESS 2.1.0)
      IF(LIBUV_VERSION VERSION_GREATER 1.5.0)
        MESSAGE(STATUS "DataStax C/C++ Driver v${CPP_VERSION} cannot use libuv v${LIBUV_VERSION}: Downgrading to libuv v1.5.0")
        SET(LIBUV_VERSION v1.5.0 CACHE STRING "libuv version" FORCE)
      ENDIF(LIBUV_VERSION VERSION_GREATER 1.5.0)
    ENDIF(CPP_DRIVER_VERSION VERSION_LESS 2.1.0)
  ENDIF(LIBUV_VERSION)
ENDIF(NOT CPP_DRIVER_VERSION)
IF(WITH_OPENSSL)
  INCLUDE(ExternalProject-OpenSSL)
  IF(NOT WITH_ZLIB)
    SET(WITH_ZLIB OFF CACHE STRING "Build with zlib support" FORCE)
  ENDIF(NOT WITH_ZLIB)
ELSE(WITH_OPENSSL)
    SET(WITH_OPENSSL OFF CACHE STRING "Build with OpenSSL support" FORCE)
    SET(WITH_ZLIB OFF CACHE STRING "Build with zlib support" FORCE)
ENDIF(WITH_OPENSSL)
OPTION(INSTALL_PREFIX, "DataStax C/C++ driver installation prefix location")
IF(NOT INSTALL_PREFIX)
  SET(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/libs CACHE STRING "DataStax C/C++ driver install prefix" FORCE)
ENDIF(NOT INSTALL_PREFIX)

##
# DataStax C/C++ driver related CMake variables
##
SET(CPP_DRIVER_LIBRARY_NAME "cpp-driver-library")
SET(CPP_DRIVER_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/cpp-driver)
SET(CPP_DRIVER_ARCHIVE_URL_PREFIX "https://github.com/datastax/cpp-driver/archive/")
SET(CPP_DRIVER_ARCHIVE_URL_SUFFIX ".tar.gz")
SET(CPP_DRIVER_ARCHIVE_URL "${CPP_DRIVER_ARCHIVE_URL_PREFIX}${CPP_DRIVER_ARCHIVE_NAME}${CPP_DRIVER_ARCHIVE_URL_SUFFIX}")

##
# Information messages about the configuration
##
SET(CPP_DRIVER_VERSION_DISPLAY v${CPP_DRIVER_VERSION})
IF(CPP_DRIVER_VERSION MATCHES master)
  SET(CPP_DRIVER_VERSION_DISPLAY master)
ENDIF(CPP_DRIVER_VERSION MATCHES master)
MESSAGE(STATUS "DataStax C/C++ Driver: ${CPP_DRIVER_VERSION_DISPLAY}")

##
# Determine library suffix
##
IF(WIN32)
  SET(CPP_DRIVER_LIBRARY_SUFFIX lib)
ELSE(WIN32)
  IF(NOT BUILD_SHARED_LIBS)
    SET(CPP_DRIVER_LIBRARY_SUFFIX a)
  ELSE(NOT BUILD_SHARED_LIBS)
    SET(CPP_DRIVER_LIBRARY_SUFFIX so)
  ENDIF(NOT BUILD_SHARED_LIBS)
ENDIF(WIN32)

##
# DataStax C/C++ driver library configuration variables
##
SET(CPP_DRIVER_INSTALL_DIR ${INSTALL_PREFIX}/cpp-driver)
IF(BUILD_SHARED_LIBS)
  SET(CPP_DRIVER_BINARY_DIR ${CPP_DRIVER_INSTALL_DIR}/bin)
ENDIF(BUILD_SHARED_LIBS)
SET(CPP_DRIVER_INCLUDE_DIR ${CPP_DRIVER_INSTALL_DIR}/include)
SET(CPP_DRIVER_LIBRARY_DIR ${CPP_DRIVER_INSTALL_DIR}/lib/${CMAKE_CXX_LIBRARY_ARCHITECTURE})
SET(CPP_DRIVER_LIBRARY cpp-driver)
SET(CPP_DRIVER_LIBRARIES ${CPP_DRIVER_LIBRARY_DIR}/${CPP_DRIVER_LIBRARY}.${CPP_DRIVER_LIBRARY_SUFFIX})

# Determine if DataStax C/C++ Driver has already been found/included
IF(NOT CPP_DRIVER_FOUND)
  # Add DataStax C/C++ driver as an external project (OpenSSL and libuv are dependencies)
  EXTERNALPROJECT_ADD(${CPP_DRIVER_LIBRARY_NAME}
    DEPENDS ${LIBUV_LIBRARY_NAME}
    PREFIX ${CPP_DRIVER_PROJECT_PREFIX}
    URL ${CPP_DRIVER_ARCHIVE_URL}
    DOWNLOAD_DIR ${CPP_DRIVER_PROJECT_PREFIX}
    INSTALL_DIR ${CPP_DRIVER_INSTALL_DIR}
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${CPP_DRIVER_INSTALL_DIR}
      -DCASS_INSTALL_HEADER=ON
      -DCASS_USE_EXTERNAL_BOOST=OFF
      -DCASS_BUILD_SHARED=OFF
      -DCASS_BUILD_STATIC=ON
      -DCASS_USE_STATIC_LIBS=ON
      -DCASS_MULTICORE_COMPILATION=ON
      -DCASS_BUILD_EXAMPLES=OFF
      -DCASS_BUILD_TESTS=OFF
      -DCASS_USE_TCMALLOC=OFF
      -DCASS_USE_OPENSSL=${WITH_OPENSSL}
      -DCASS_USE_ZLIB=${WITH_ZLIB}
      -DLIBUV_ROOT_DIR=${LIBUV_INSTALL_DIR}
      -DOPENSSL_ROOT_DIR=${OPENSSL_INSTALL_DIR}
      -DZLIB_ROOT_DIR=${ZLIB_INSTALL_DIR}
      -D_OPENSSL_INCLUDEDIR=${OPENSSL_INCLUDE_DIR}
      -D_OPENSSL_LIBDIR=${OPENSSL_LIBRARY_DIR}
      -D_OPENSSL_VERSION=${OPENSSL_VERSION}
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1)

  # Determine if zlib should be added as a dependency
  IF(WITH_OPENSSL)
    ADD_DEPENDENCIES(${CPP_DRIVER_LIBRARY_NAME} ${OPENSSL_LIBRARY_NAME})
    IF(WITH_ZLIB)
      ADD_DEPENDENCIES(${CPP_DRIVER_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME})
    ENDIF(WITH_ZLIB)
  ENDIF(WITH_OPENSSL)

  # Indicate DataStax C/C++ Driver has been included
  SET(CPP_DRIVER_FOUND ON CACHE BOOL "DataStax C/C++ Driver Found" FORCE)

  # Create the folder properties for the external project
  SET_TARGET_PROPERTIES(${CPP_DRIVER_LIBRARY_NAME} PROPERTIES FOLDER "external/cpp-driver")
ENDIF(NOT CPP_DRIVER_FOUND)

##
# Update the include directory to use DataStax C/C++ driver
##
INCLUDE_DIRECTORIES(${CPP_DRIVER_INCLUDE_DIR})

##
# DataStax C/C++ driver library header files
##
SET(CPP_DRIVER_INCLUDE_FILES ${CPP_DRIVER_INCLUDE_DIR}/cassandra.h)
SET_SOURCE_FILES_PROPERTIES(${CPP_DRIVER_INCLUDE_FILES} PROPERTIES GENERATED TRUE)
SOURCE_GROUP("Header Files\\cpp-driver" FILES ${CPP_DRIVER_INCLUDE_FILES})
