##
# CMake Modules - RapidXml External Project
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
# RapidXml related CMake variables
##
SET(RAPIDXML_LIBRARY_NAME "rapidxml-library")
SET(RAPIDXML_PROJECT_PREFIX ${CMAKE_BINARY_DIR}/external/rapidxml)
SET(RAPIDXML_ARCHIVE_URL "http://downloads.sourceforge.net/project/rapidxml/rapidxml/rapidxml%201.13/rapidxml-1.13.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Frapidxml%2F&ts=1435949731&use_mirror=colocrossing")
SET(RAPIDXML_ARCHIVE_NAME rapidxml-1.13.zip)

##
# Information messages about the configuration
##
MESSAGE(STATUS "RapidXml: v1.13")

# Determine if RapidXML has already been found/included
IF(NOT RAPIDXML_FOUND)
  ##
  # Add RapidXml as an external project (header only project)
  ##
  EXTERNALPROJECT_ADD(${RAPIDXML_LIBRARY_NAME}
    PREFIX ${RAPIDXML_PROJECT_PREFIX}
    URL ${RAPIDXML_ARCHIVE_URL}
    DOWNLOAD_NAME ${RAPIDXML_ARCHIVE_NAME}
    DOWNLOAD_DIR ${RAPIDXML_PROJECT_PREFIX}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1)

  # Indicate RapidXML has been included
  SET(RAPIDXML_FOUND ON CACHE BOOL "RapidXML Found" FORCE)

  # Create the folder properties for the external project
  SET_TARGET_PROPERTIES(${RAPIDXML_LIBRARY_NAME} PROPERTIES FOLDER "external/RapidXml")
ENDIF(NOT RAPIDXML_FOUND)

##
# Update the include directory to use RapidXml
##
EXTERNALPROJECT_GET_PROPERTY(${RAPIDXML_LIBRARY_NAME} SOURCE_DIR)
SET(RAPIDXML_INCLUDE_DIR ${SOURCE_DIR})
INCLUDE_DIRECTORIES(${RAPIDXML_INCLUDE_DIR})

##
# RapidXml library header files
##
SET(RAPIDXML_INCLUDE_FILES ${RAPIDXML_INCLUDE_DIR}/rapidxml.hpp
  ${RAPIDXML_INCLUDE_DIR}/rapidxml_iterators.hpp
  ${RAPIDXML_INCLUDE_DIR}/rapidxml_print.hpp
  ${RAPIDXML_INCLUDE_DIR}/rapidxml_utils.hpp)
SET_SOURCE_FILES_PROPERTIES(${RAPIDXML_INCLUDE_FILES} PROPERTIES GENERATED TRUE)
SOURCE_GROUP("Header Files\\RapidXml" FILES ${RAPIDXML_INCLUDE_FILES})
