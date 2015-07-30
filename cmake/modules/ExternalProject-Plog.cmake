##
# CMake Modules - Plog External Project
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
# Plog related CMake options
##
OPTION(PLOG_VERSION "Plog version")
IF(NOT PLOG_VERSION)
  SET(PLOG_VERSION master)
  SET(PLOG_ARCHIVE_NAME ${PLOG_VERSION})
ELSE(NOT PLOG_VERSION)
  SET(PLOG_ARCHIVE_NAME ${PLOG_VERSION})
ENDIF(NOT PLOG_VERSION)

##
# Plog related CMake variables
##
SET(PLOG_LIBRARY_NAME plog-library)
SET(PLOG_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/plog)
SET(PLOG_ARCHIVE_URL_PREFIX "https://github.com/SergiusTheBest/plog/archive/")
SET(PLOG_ARCHIVE_URL_SUFFIX ".tar.gz")
SET(PLOG_ARCHIVE_URL "${PLOG_ARCHIVE_URL_PREFIX}${PLOG_ARCHIVE_NAME}${PLOG_ARCHIVE_URL_SUFFIX}")

##
# Information messages about the configuration
##
SET(PLOG_VERSION_DISPLAY v${PLOG_VERSION})
IF(PLOG_VERSION MATCHES master)
  SET(PLOG_VERSION_DISPLAY master)
ENDIF(PLOG_VERSION MATCHES master)
MESSAGE(STATUS "Plog: ${PLOG_VERSION_DISPLAY}")

##
# Add Plog as an external project (header only project)
##
EXTERNALPROJECT_ADD(${PLOG_LIBRARY_NAME}
  PREFIX ${PLOG_PROJECT_PREFIX}
  URL ${PLOG_ARCHIVE_URL}
  DOWNLOAD_DIR ${PLOG_PROJECT_PREFIX}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  LOG_DOWNLOAD 1)

##
# Update the include directory to use Plog
##
EXTERNALPROJECT_GET_PROPERTY(${PLOG_LIBRARY_NAME} SOURCE_DIR)
SET(PLOG_INCLUDE_DIR ${SOURCE_DIR}/include)
INCLUDE_DIRECTORIES(${PLOG_INCLUDE_DIR})

##
# Plog library header files
##
SET(PLOG_INCLUDE_FILES ${PLOG_INCLUDE_DIR}/plog/Log.h)
SET_SOURCE_FILES_PROPERTIES(${PLOG_INCLUDE_FILES} GENERATED)
SOURCE_GROUP("Header Files\\Plog" FILES ${PLOG_INCLUDE_FILES})
SET_TARGET_PROPERTIES(${PLOG_LIBRARY_NAME} PROPERTIES FOLDER "external/plog")
