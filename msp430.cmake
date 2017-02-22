##########################################################
# TOOLCHAIN FILE FOR MSP430
# Author: Viktor Schneider <info@vjs.io>
##########################################################

##########################################################
# SET SYSTEM OPTIONS
##########################################################
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION})
set(CMAKE_SYSTEM_PROCESSOR msp430)
set(CMAKE_CROSSCOMPILING 1)
set(DEVICE "MSP430g2553" CACHE STRING "MSP430 Microcontroller")

##########################################################
# SKIP COMPILER CHECKS
##########################################################
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

##########################################################
# FIND MSP430 C COMPILER
##########################################################
if(NOT MSP430_CC)
    find_program(MSP430_CC msp430-gcc)
endif()
if(NOT MSP430_CC)
    find_program(MSP430_CC msp430-elf-gcc)
endif()
if(NOT MSP430_CC)
    message(FATAL_ERROR "MSP430 C compiler was not found\nSet compiler path with MSP430_CC=/path/to/compiler")
else()
    message(STATUS "Found MSP430 C compiler: ${MSP430_CC}")
endif()

##########################################################
# FIND MSP430 C++ COMPILER
##########################################################
if(NOT MSP430_CXX)
    find_program(MSP430_CXX msp430-g++)
endif()
if(NOT MSP430_CXX)
    find_program(MSP430_CXX msp430-elf-g++)
endif()
if(NOT MSP430_CXX)
    message(FATAL_ERROR "MSP430 C++ compiler was not found\nSet compiler path with MSP430_CXX=/path/to/compiler")
else()
    message(STATUS "Found MSP430 C++ compiler: ${MSP430_CXX}")
endif()

##########################################################
# FIND MSP430 LIB AND INCLUDE FOLDER
##########################################################
if (NOT MSP430_COMPILER_DIR)
    get_filename_component(MSP430_COMPILER_REALPATH ${MSP430_CXX} REALPATH)
    get_filename_component(MSP430_COMPILER_DIR ${MSP430_COMPILER_REALPATH}/ DIRECTORY)
    get_filename_component(MSP430_COMPILER_DIR ${MSP430_COMPILER_DIR}/../ REALPATH)
    if (EXISTS ${MSP430_COMPILER_DIR}/lib AND EXISTS ${MSP430_COMPILER_DIR}/include)
        message(STATUS "Found lib and include folder in ${MSP430_COMPILER_DIR}")
        link_directories(${MSP430_COMPILER_DIR}/lib)
        include_directories(${MSP430_COMPILER_DIR}/include)
    else()
        message(FATAL_ERROR "MSP430 lib and include directories could not be found\nSet path to lib and include directory manual with MSP430_COMPILER_DIR=/path/to/directory")
    endif()
endif()

##########################################################
# SET C AND CXX COMPILER
##########################################################
set(CMAKE_C_COMPILER ${MSP430_CC})
set(CMAKE_CXX_COMPILER ${MSP430_CXX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

##########################################################
# SET MICROCONTROLLER AND COMPILE FLAGS
##########################################################
if (DEVICE)
    message(STATUS "Target MSP430: ${DEVICE}")
else()
    message(FATAL_ERROR "No microcontroller declared\nSet microcontroller with DEVICE=MICROCONTROLLER_TYPE")
endif()

set(CMAKE_C_FLAGS  "-I ${MSP430_COMPILER_DIR}/include -mmcu=${DEVICE} -O2 -g -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS  "-I ${MSP430_COMPILER_DIR}/include -mmcu=${DEVICE} -O2 -g -ffunction-sections -fdata-sections")
set(CMAKE_CXX_LINK_FLAGS "-L ${MSP430_COMPILER_DIR}/include -Wl,-gc-sections")