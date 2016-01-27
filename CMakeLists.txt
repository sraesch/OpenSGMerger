cmake_minimum_required(VERSION 2.8)
project(OpenSGMerger)

set(CMAKE_CXX_STANDARD 11)

set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH}
    ${CMAKE_SOURCE_DIR}/CMake)

set(SRC
    main.cpp
)

set(HDR
)

# handle external packages
find_package(OpenSG)

set(Boost_USE_MULTITHREADED ON)
find_package(Boost 1.55 REQUIRED COMPONENTS system thread)
add_definitions(-D BOOST_ALL_NO_LIB)

# system includes
include_directories(SYSTEM ${Boost_INCLUDE_DIR})
include_directories(SYSTEM ${OpenSG_INCLUDE_DIR})

# create executable
add_executable(${PROJECT_NAME} ${SRC} ${HDR})

# links to external libraries
target_link_libraries(${PROJECT_NAME} ${OpenSG_OSGSystem_LIBRARY})
target_link_libraries(${PROJECT_NAME} ${OpenSG_OSGBase_LIBRARY})

# add install routine
install(TARGETS ${PROJECT_NAME} DESTINATION .)
