##
# CMake Modules - Visual Studio Environment Script
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

# Ensure Visual Studio has been detected
IF(MSVC_VERSION)
  # Determine the version number of MSVC for environment variable
  MATH(EXPR VSCOMNTOOLS_VERSION "${MSVC_VERSION} - 600")
  IF(MSVC_VERSION VERSION_GREATER 1900)
    MATH(EXPR VSCOMNTOOLS_VERSION "${VSCOMNTOOLS_VERSION} - 100")
  ENDIF(MSVC_VERSION VERSION_GREATER 1900)
  STRING(SUBSTRING ${VSCOMNTOOLS_VERSION} 0, 3, VSCOMNTOOLS_VERSION)
  SET(VSCOMNTOOLS VS${VSCOMNTOOLS_VERSION}COMNTOOLS)

  # Assign the Visual Studio command prompt environment script
  SET(VCVARSALL_SCRIPT "$ENV{${VSCOMNTOOLS}}/../../VC/vcvarsall.bat")

  # Create the Visual Studio environment script variable
  IF(EXISTS ${VCVARSALL_SCRIPT})
    # Determine the target architecture for the Visual Studio environment
    SET(VCVARSALL_ARCHITECTURE x86)
    IF(CMAKE_CL_64)
      SET(VCVARSALL_ARCHITECTURE amd64)
    ENDIF(CMAKE_CL_64)

    # Assign the architecture to the Visual Studio environment
    FILE(TO_NATIVE_PATH ${VCVARSALL_SCRIPT} VCVARSALL_SCRIPT)
  ELSE(EXISTS ${VCVARSALL_SCRIPT})
    # Reset the used variables and produce a warning
    UNSET(VSCOMNTOOLS)
    UNSET(VCVARSALL_SCRIPT)
    UNSET(VCVARSALL_ARCHITECTURE)
    MESSAGE(WARNING "Unable to locate Visual Studio environment script")
  ENDIF(EXISTS ${VCVARSALL_SCRIPT})
ENDIF(MSVC_VERSION)
