#
# FindOpenSG
#
# Locates OpenSG and sets the following variables:
#
# OpenSG_FOUND                          - True if IRBaseLibs were found
# OpenSG_INCLUDE_DIR                    - The top level include directory
# OpenSG_LIBRARY_DIR                    - The directory that contains all library files
# OpenSG_CONFIGURED                     - True if OSGConfigured.h is found
#
# Optionally, find_package can be called with the COMPONENTS parameter to specify single libraries.
# For each component listed in ${COMPONENTS}, a separate set of variables is generated:
#
# OpenSG_${COMPONENT}_FOUND             - True if ${COMPONENT} was found (either debug or release)
# OpenSG_${COMPONENT}_LIBRARY           - The full path to the release version of the library
# OpenSG_${COMPONENT}_LIBRARY_RELEASE   - The full path to the release version of the library
# OpenSG_${COMPONENT}_LIBRARY_DEBUG     - The full path to the debug version of the library
#
# Author: Tobias Alexander Franke
#

if (OpenSG_FIND_COMPONENTS)
    set(COMPONENTS ${OpenSG_FIND_COMPONENTS})
else()
    set(COMPONENTS
        OSGBase
        OSGSystem
        OSGContrib
        OSGContribDynamicTerrain
        OSGContribFhs
        OSGWindowGLUT
        OSGWindowQT
        OSGWindowQT4
    )

    if(WIN32)
        list(APPEND COMPONENTS OSGWindowWIN32)
    elseif(UNIX AND NOT CYGWIN)
        list(APPEND COMPONENTS OSGWindowX)

        if(APPLE)
            list(APPEND COMPONENTS OSGWindowCarbon OSGWindowCocoa OSGWindowCoreGL)
        endif()
    endif()
endif()

# check for both types of variables
if(NOT $ENV{OSG_ROOT} STREQUAL "")
    set(OSGROOT $ENV{OSG_ROOT})
elseif(NOT $ENV{OSGROOT} STREQUAL "")
    set(OSGROOT $ENV{OSGROOT})
else()
    set(OSGROOT $ENV{IR_ROOT}/OpenSG)
endif()


# find root dir instead of include and lib
find_path(OpenSG_ROOT
    NAMES include/OpenSG/OSGNode.h
    PATHS
    ${OpenSG_ROOT}
    ${OpenSG_ROOT}/installed
    ${OpenSG_ROOT}/Build
    ${OpenSG_ROOT}/Build/*
    ${OpenSG_ROOT}/Build/*/installed
    ${OpenSG_ROOT}/Builds
    ${OpenSG_ROOT}/Builds/*
    ${OpenSG_ROOT}/Builds/*/installed
    ${OSGROOT}
    ${OSGROOT}/Build
    ${OSGROOT}/Build/*
    ${OSGROOT}/Build/*/installed
    ${OSGROOT}/Builds
    ${OSGROOT}/Builds/*
    ${OSGROOT}/Builds/*/installed
    ${CMAKE_SOURCE_DIR}/../OpenSG/Builds/*
    $ENV{ProgramFiles}/OpenSG
    ~/Library/Frameworks/OpenSG
    /Library/Frameworks/OpenSG
    /usr/local
    /usr
    /sw
    /opt/local
    /opt
)

set(INCLUDE_SEARCH_PATHS
    ${OpenSG_ROOT}/include
    ${OpenSG_ROOT}/installed/include
    ${OpenSG_ROOT}/Build/installed/include
    ${OpenSG_ROOT}/Build/*/installed/include
    ${OpenSG_ROOT}/Builds/include
    ${OpenSG_ROOT}/Builds/*/include
    ${OpenSG_INCLUDE_DIR}
    $ENV{ProgramFiles}/OpenSG/include
    ~/Library/Frameworks/OpenSG/include
    /Library/Frameworks/OpenSG/include
    /usr/local/include
    /usr/include
    /sw/include
    /opt/local/include
    /opt/include
)

find_path(OpenSG_INCLUDE_DIR
    NAMES OpenSG/OSGNode.h
    PATHS
    ${INCLUDE_SEARCH_PATHS}
)

find_file(OpenSG_CONFIGURED_HEADER
    NAMES OpenSG/OSGConfigured.h
    PATHS
    ${INCLUDE_SEARCH_PATHS}
)

mark_as_advanced(OpenSG_CONFIGURED_HEADER)

set(OpenSG_CONFIGURED FALSE)
if(OpenSG_CONFIGURED_HEADER)
    set(OpenSG_CONFIGURED TRUE)
endif()

set(LIB_SEARCH_PATHS
    ${OpenSG_ROOT}/lib
    ${OpenSG_ROOT}/lib64
    ${OpenSG_ROOT}/installed/lib/rel
    ${OpenSG_ROOT}/installed/lib64
    ${OpenSG_ROOT}/installed/lib
    ${OpenSG_ROOT}/Build/lib
    ${OpenSG_ROOT}/Build/*/lib
    ${OpenSG_ROOT}/Build/*/lib64
    ${OpenSG_ROOT}/Build/installed/lib
    ${OpenSG_ROOT}/Build/*/installed/lib
    ${OpenSG_ROOT}/Build/*/installed/lib64
    ${OpenSG_ROOT}/Builds/lib
    ${OpenSG_ROOT}/Builds/*/lib
    ${OpenSG_ROOT}/Builds/*/lib64
    ${OpenSG_LIBRARY_DIR}
    $ENV{ProgramFiles}/OpenSG/lib
    /usr/local/lib64
    /usr/local/lib
    /usr/lib64
    /usr/lib
    /sw/lib
    /opt/local/lib
    /opt/lib
)

set(PATH_SUFFIXES_RELEASE
    opt
    optdbg
    Release
    rel
)

set(PATH_SUFFIXES_DEBUG
    dbg
    Debug
)

if(WIN32)
    set(OpenSG_DEBUG_SUFFIX "D" CACHE STRING "The suffix used for the debug libraries.")
else()
    set(OpenSG_DEBUG_SUFFIX "" CACHE STRING "The suffix used for the debug libraries.")
endif()
mark_as_advanced(OpenSG_DEBUG_SUFFIX)

foreach(COMPONENT ${COMPONENTS})
    find_library(OpenSG_${COMPONENT}_LIBRARY_RELEASE
        ${COMPONENT}
        PATHS
        ${LIB_SEARCH_PATHS}
        PATH_SUFFIXES
        ${PATH_SUFFIXES_RELEASE}
    )

    find_library(OpenSG_${COMPONENT}_LIBRARY_DEBUG
        ${COMPONENT}${OpenSG_DEBUG_SUFFIX}
        PATHS
        ${LIB_SEARCH_PATHS}
        PATH_SUFFIXES
        ${PATH_SUFFIXES_DEBUG}
    )

    set(OpenSG_${COMPONENT}_FOUND FALSE)
    set(OpenSG_${COMPONENT}_PARTS "")

    if(OpenSG_${COMPONENT}_LIBRARY_RELEASE)
        set(OpenSG_${COMPONENT}_FOUND TRUE)
        list(APPEND OpenSG_${COMPONENT}_PARTS optimized ${OpenSG_${COMPONENT}_LIBRARY_RELEASE})
    endif()

    if(OpenSG_${COMPONENT}_LIBRARY_DEBUG)
        set(OpenSG_${COMPONENT}_FOUND TRUE)
        list(APPEND OpenSG_${COMPONENT}_PARTS debug ${OpenSG_${COMPONENT}_LIBRARY_DEBUG})
    endif()

    separate_arguments(OpenSG_${COMPONENT}_PARTS)
    if(OpenSG_${COMPONENT}_FOUND)
        set(OpenSG_${COMPONENT}_LIBRARY "${OpenSG_${COMPONENT}_PARTS}" CACHE FILEPATH "The OpenSG ${COMPONENT} libraries." FORCE)
    endif()

    mark_as_advanced(
        OpenSG_${COMPONENT}_LIBRARY_RELEASE
        OpenSG_${COMPONENT}_LIBRARY_DEBUG
        OpenSG_${COMPONENT}_LIBRARY
    )
endforeach()

if(OpenSG_OSGBase_FOUND)
    if (OpenSG_OSGBase_LIBRARY_RELEASE)
        get_filename_component(OpenSG_LIBRARY_DIR ${OpenSG_OSGBase_LIBRARY_RELEASE} PATH CACHE)
    elseif(OpenSG_OSGBase_LIBRARY_DEBUG)
        get_filename_component(OpenSG_LIBRARY_DIR ${OpenSG_OSGBase_LIBRARY_DEBUG} PATH CACHE)
    endif()
else()
    set(OpenSG_LIBRARY_DIR "OpenSG_LIBRARY_DIR-NOTFOUND" CACHE PATH "Path to the OpenSG library directory.")
endif()

set(OpenSG_FOUND FALSE)
if(OpenSG_INCLUDE_DIR AND OpenSG_LIBRARY_DIR AND OpenSG_OSGBase_FOUND)
   set(OpenSG_FOUND TRUE)
   mark_as_advanced(OpenSG_INCLUDE_DIR OpenSG_LIBRARY_DIR)
else()
    if (OpenSG_FIND_REQUIRED)
        message(SEND_ERROR "Could NOT find OpenSG!")
    endif()
    mark_as_advanced(OpenSG_INCLUDE_DIR OpenSG_LIBRARY_DIR) # we have OpenSG_ROOT
endif()
