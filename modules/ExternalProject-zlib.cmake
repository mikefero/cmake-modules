##
# CMake Modules - zlib External Project
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
# zlib related CMake options
##
OPTION(ZLIB_VERSION "zlib version")
IF(NOT ZLIB_VERSION)
  SET(ZLIB_VERSION master)
  SET(ZLIB_ARCHIVE_NAME ${ZLIB_VERSION})
ELSE(NOT ZLIB_VERSION)
  SET(ZLIB_ARCHIVE_NAME v${ZLIB_VERSION})
ENDIF(NOT ZLIB_VERSION)
OPTION(BUILD_SHARED "Build shared libraries" OFF)
OPTION(INSTALL_PREFIX, "zlib installation prefix location")
IF(NOT INSTALL_PREFIX)
  SET(INSTALL_PREFIX "${CMAKE_BINARY_DIR}/libs")
ENDIF(NOT INSTALL_PREFIX)
IF(NOT CMAKE_BUILD_TYPE)
  MESSAGE(STATUS "Defaulting to Release build")
  SET(CMAKE_BUILD_TYPE RELEASE FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

##
# zlib related CMake variables
##
SET(ZLIB_LIBRARY_NAME "zlib-library")
SET(ZLIB_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/zlib)
SET(ZLIB_ARCHIVE_URL_PREFIX "https://github.com/madler/zlib/archive/")
SET(ZLIB_ARCHIVE_URL_SUFFIX ".tar.gz")
SET(ZLIB_ARCHIVE_URL "${ZLIB_ARCHIVE_URL_PREFIX}${ZLIB_ARCHIVE_NAME}${ZLIB_ARCHIVE_URL_SUFFIX}")
SET(ZLIB_INSTALL_DIR "${INSTALL_PREFIX}/zlib")

##
# Ensure dependencies are met
##
IF(WIN32)
  # Make sure Visual Studio is available
  IF(NOT MSVC)
    MESSAGE(FATAL_ERROR "Visual Studio is required to build zlib")
  ENDIF(NOT MSVC)

  # Make sure the environmental configure script is available
  INCLUDE(Windows-MSVC-EnvironmentScript)
  IF(NOT VCVARSALL_SCRIPT)
    MESSAGE(FATAL_ERROR "Visual Studio environment script is required to build zlib")
  ENDIF(NOT VCVARSALL_SCRIPT)
ENDIF(WIN32)

##
# Information messages about the configuration
##
SET(ZLIB_VERSION_DISPLAY v${ZLIB_VERSION})
IF(ZLIB_VERSION MATCHES master)
  SET(ZLIB_VERSION_DISPLAY master)
ENDIF(ZLIB_VERSION MATCHES master)
MESSAGE(STATUS "zlib: ${ZLIB_VERSION_DISPLAY} [${CMAKE_BUILD_TYPE}]")

##
# Determine library suffix
##
IF(WIN32)
  SET(ZLIB_LIBRARY_SUFFIX lib)
ELSE(WIN32)
  IF(NOT BUILD_SHARED)
    SET(ZLIB_LIBRARY_SUFFIX a)
  ELSE(NOT BUILD_SHARED)
    SET(ZLIB_LIBRARY_SUFFIX so)
  ENDIF(NOT BUILD_SHARED)
ENDIF(WIN32)

##
# zlib library configuration variables
##
SET(ZLIB_INSTALL_DIR "${INSTALL_PREFIX}/zlib")
IF(BUILD_SHARED)
  SET(ZLIB_BINARY_DIR "${ZLIB_INSTALL_DIR}/bin")
ENDIF(BUILD_SHARED)
SET(ZLIB_INCLUDE_DIR "${ZLIB_INSTALL_DIR}/include")
SET(ZLIB_LIBRARY_DIR "${ZLIB_INSTALL_DIR}/lib")
IF(WIN32)
  SET(ZLIB_SHARED_LIBRARY zlib)
  SET(ZLIB_STATIC_LIBRARY zlibstatic)
  SET(ZLIB_SHARED_DEBUG_LIBRARY ${ZLIB_SHARED_LIBRARY}d)
  SET(ZLIB_STATIC_DEBUG_LIBRARY ${ZLIB_STATIC_LIBRARY}d)
ENDIF(WIN32)
SET(ZLIB_SHARED_LIBRARIES ${ZLIB_INSTALL_DIR}/${ZLIB_SHARED_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
SET(ZLIB_STATIC_LIBRARIES ${ZLIB_INSTALL_DIR}/${ZLIB_STATIC_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
SET(ZLIB_SHARED_DEBUG_LIBRARIES ${ZLIB_INSTALL_DIR}/${ZLIB_SHARED_DEBUG_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})
SET(ZLIB_STATIC_DEBUG_LIBRARIES ${ZLIB_INSTALL_DIR}/${ZLIB_STATIC_DEBUG_LIBRARY}.${ZLIB_LIBRARY_SUFFIX})

# Indicate zlib can be built
SET(ZLIB_FOUND TRUE)

# Add zlib as an external project
EXTERNALPROJECT_ADD(${ZLIB_LIBRARY_NAME}
  PREFIX ${ZLIB_PROJECT_PREFIX}
  URL ${ZLIB_ARCHIVE_URL}
  DOWNLOAD_DIR ${ZLIB_PROJECT_PREFIX}
  INSTALL_DIR ${ZLIB_INSTALL_DIR}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=${ZLIB_INSTALL_DIR}
    -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    -DASM686=OFF # Disable assembly compiling (does not build on all compilers)
    -DASM64=OFF # Disable assembly compiling (does not build on all compilers)
  BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config RELEASE --target install
    COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --config DEBUG
  LOG_DOWNLOAD 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_INSTALL 1)

##
# zlib library header files
##
SET(ZLIB_INCLUDE_FILES ${ZLIB_INCLUDE_DIR}/zlib.h)
SET_SOURCE_FILES_PROPERTIES(${ZLIB_INCLUDE_FILES} GENERATED)
SOURCE_GROUP("Header Files\\zlib" FILES ${ZLIB_INCLUDE_FILES})
SET_TARGET_PROPERTIES(${ZLIB_LIBRARY_NAME} PROPERTIES FOLDER "external/zlib")
