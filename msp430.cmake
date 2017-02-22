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
# FIND MSP430 SIZE PROGRAM
##########################################################
if(NOT MSP430_SIZE)
    find_program(MSP430_SIZE msp430-size)
endif()
if(NOT MSP430_SIZE)
    find_program(MSP430_SIZE msp430-elf-size)
endif()
if(NOT MSP430_SIZE)
    message(STATUS "MSP430 Size program was not found")
else()
    message(STATUS "Found MSP430 Size program: ${MSP430_SIZE}")
endif()

##########################################################
# FIND MSP430 DEBUGGER
##########################################################
if(NOT MSP430_GDB)
    find_program(MSP430_GDB msp430-gdb)
endif()
if(NOT MSP430_GDB)
    find_program(MSP430_GDB msp430-elf-gdb)
endif()
if(NOT MSP430_GDB)
    message(STATUS "MSP430 Debugger was not found")
else()
    message(STATUS "Found MSP430 Debugger: ${MSP430_GDB}")
endif()

##########################################################
# FIND MSP430 OBJDUMP
##########################################################
if(NOT MSP430_OBJDUMP)
    find_program(MSP430_OBJDUMP msp430-objdump)
endif()
if(NOT MSP430_OBJDUMP)
    find_program(MSP430_OBJDUMP msp430-elf-objdump)
endif()
if(NOT MSP430_OBJDUMP)
    message(STATUS "MSP430 objdump was not found")
else()
    message(STATUS "Found MSP430 objdump: ${MSP430_OBJDUMP}")
endif()

##########################################################
# FIND MSP430 OBJCOPY
##########################################################
if(NOT MSP430_OBJCOPY)
    find_program(MSP430_OBJCOPY msp430-objcopy)
endif()
if(NOT MSP430_OBJCOPY)
    find_program(MSP430_OBJCOPY msp430-elf-objcopy)
endif()
if(NOT MSP430_OBJCOPY)
    message(STATUS "MSP430 objcopy was not found")
else()
    message(STATUS "Found MSP430 objcopy: ${MSP430_OBJCOPY}")
endif()

##########################################################
# FIND MSP430 Flasher
##########################################################
if(NOT MSP430_FLASHER)
    find_program(MSP430_FLASHER msp430-flasher)
endif()
if(NOT MSP430_FLASHER)
    find_program(MSP430_FLASHER msp430flasher)
endif()
if(NOT MSP430_FLASHER)
    find_program(MSP430_FLASHER MSP430Flasher)
endif()
if(NOT MSP430_FLASHER)
    message(STATUS "MSP430 Flasher was not found")
else()
    message(STATUS "Found MSP430 Flasher: ${MSP430_FLASHER}")
endif()

##########################################################
# FIND MSP430 LIB AND INCLUDE FOLDER
##########################################################
if (NOT MSP430_COMPILER_DIR)
    get_filename_component(MSP430_COMPILER_REALPATH ${MSP430_CXX} REALPATH)
    get_filename_component(MSP430_COMPILER_DIR ${MSP430_COMPILER_REALPATH}/ DIRECTORY)
    get_filename_component(MSP430_COMPILER_DIR ${MSP430_COMPILER_DIR}/../ REALPATH)
    if (EXISTS ${MSP430_COMPILER_DIR}/lib AND EXISTS ${MSP430_COMPILER_DIR}/include)
        message(STATUS "Found MSP430 lib and include folder in ${MSP430_COMPILER_DIR}")
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
# SET TARGET MICROCONTROLLER
##########################################################
function(msp430_set_device MCU)
    set(DEVICE ${MCU} PARENT_SCOPE)
    message(STATUS "Target device: ${DEVICE}")
endfunction()

##########################################################
# COMPILE EXECUTABLE
##########################################################
function(msp430_add_executable_elf EXECUTABLE)
    if(NOT DEVICE)
        message(FATAL_ERROR "No microcontroller declared\nSet microcontroller with DEVICE=MICROCONTROLLER_TYPE")
    endif()
    add_executable(${EXECUTABLE}.elf ${ARGN})
    set_target_properties(${EXECUTABLE}.elf PROPERTIES
            COMPILE_FLAGS "-I ${MSP430_COMPILER_DIR}/include -mmcu=${DEVICE} -O2 -g"
            LINK_FLAGS "-I ${MSP430_COMPILER_DIR}/include -mmcu=${DEVICE} -O2 -L ${MSP430_COMPILER_DIR}/include -g")
    if(MSP430_SIZE)
        add_custom_command(TARGET ${EXECUTABLE}.elf POST_BUILD COMMAND ${MSP430_SIZE} ${EXECUTABLE}.elf)
    endif()
endfunction()

##########################################################
# GENERATE ASSEMBLER LISTING
##########################################################
function(msp430_add_executable_listing EXECUTABLE)
    if(NOT MSP430_OBJDUMP)
        message(FATAL_ERROR "MSP430 objdump was not found\nSet path with MSP430_OBJDUMP=/path/to/objdump")
    endif()
    add_custom_command(TARGET ${EXECUTABLE}.elf POST_BUILD COMMAND
            ${MSP430_OBJDUMP} -DS ${EXECUTABLE}.elf > ${EXECUTABLE}.lst)
endfunction()

##########################################################
# GENERATE HEX FILE
##########################################################
function(msp430_add_executable_hex EXECUTABLE)
    if (NOT MSP430_OBJCOPY)
        message(FATAL_ERROR "MSP430 objcopy was not found\nSet path with MSP430_OBJCOPY=/path/to/objcopy")
    endif()
    add_custom_target(${EXECUTABLE}.hex COMMAND
            ${MSP430_OBJCOPY} -O ihex ${EXECUTABLE}.elf ${EXECUTABLE}.hex
            DEPENDS ${EXECUTABLE}.elf)
endfunction()

##########################################################
# UPLOAD EXECUTABLE
##########################################################
function(msp430_add_executable_upload EXECUTABLE)
    if(NOT MSP430_FLASHER)
        message(FATAL_ERROR "MSP430 Flasher was not found\nSet Flasher path with MSP430_Flasher=/path/to/flasher")
    endif()
    add_custom_target(${EXECUTABLE}.upload COMMAND
            ${MSP430_FLASHER} -n ${DEVICE} -w ${EXECUTABLE}.hex -v -g -z [VCC]
            DEPENDS ${EXECUTABLE}.hex)
endfunction()
