##
# Test zlib External Project CMake File
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
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)
PROJECT(zlib)
SET(PROJECT_DISPLAY_NAME "ExternalProject-zlib Test")
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)

##
# Ensure build requirements
##
IF(NOT UNIX AND NOT WIN32)
  MESSAGE(FATAL_ERROR "Currently only *nix and Windows systems are supported")
ENDIF()

##
# Use modules not in standard package
##
SET(PROJECT_MODULE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../modules)
SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_MODULE_DIR})

##
# Include CMake modules
##
INCLUDE(ExternalProject-zlib)

SET(GENERATED_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/main.cpp)
FILE(REMOVE ${GENERATED_SOURCE_FILE})
FILE(WRITE ${GENERATED_SOURCE_FILE} "int main () { return 0; }")

ADD_EXECUTABLE(${PROJECT_NAME} ${GENERATED_SOURCE_FILE})
ADD_DEPENDENCIES(${PROJECT_NAME} ${ZLIB_LIBRARY_NAME})

