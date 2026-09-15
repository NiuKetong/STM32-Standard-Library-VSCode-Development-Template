# Set the minimum version of CMake that can be used
cmake_minimum_required(VERSION 3.20)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)

# Set target definition variables required by the toolchain file
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/target.cmake)

# Set the toolchain file for cross-compilation
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/gcc-arm-none-eabi.cmake)

# Project definition
project(stm32)

# Enable CMake support for ASM and C/CPP languages
enable_language(C ASM)

set(PROJECT_NAME stm32)

# Create an executable object type
add_executable(${PROJECT_NAME})

# Include additional CMake files for flags, components, and files
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/flags.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/components.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/files.cmake)

# Add sources to executable/library
set(STDPERIPH_SRC_DIR
  ${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty/STM32F10x_StdPeriph_Driver/Libraries/STM32F10x_StdPeriph_Driver/src
)

file(GLOB STDPERIPH_SOURCES CONFIGURE_DEPENDS
  ${STDPERIPH_SRC_DIR}/*.c
)

target_sources(${PROJECT_NAME} PRIVATE
  # CMSIS system source
  ThirdParty/STM32F10x_StdPeriph_Driver/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c

  # All STM32F10x Standard Peripheral Library sources
  ${STDPERIPH_SOURCES}
)

# Generate firmware formats consumed by the download task after linking.
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_OBJCOPY}
          -O ihex
          $<TARGET_FILE_NAME:${PROJECT_NAME}>
          ${PROJECT_NAME}.hex
  COMMAND ${CMAKE_OBJCOPY}
          -O binary
          $<TARGET_FILE_NAME:${PROJECT_NAME}>
          ${PROJECT_NAME}.bin
  COMMENT "Generating ${PROJECT_NAME}.hex and ${PROJECT_NAME}.bin"
  VERBATIM
)

# Add include directories
target_include_directories(${PROJECT_NAME} PRIVATE
  # User defined include directories
  Src/User
  Src/System
  Src/Software
  Src/Hardware
  Src/Application
  ThirdParty/STM32F10x_StdPeriph_Driver/Libraries/CMSIS/CM3/CoreSupport
  ThirdParty/STM32F10x_StdPeriph_Driver/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x
  ThirdParty/STM32F10x_StdPeriph_Driver/Libraries/STM32F10x_StdPeriph_Driver/inc
)

# Compiler options
target_compile_options(${PROJECT_NAME} PRIVATE
  # User defined compiler options
)

# Add additional defined symbols
target_compile_definitions(${PROJECT_NAME} PRIVATE
  # Add additional defined symbols here
  STM32F10X_MD
  USE_STDPERIPH_DRIVER
)

# Linker options
target_link_options(${PROJECT_NAME} PRIVATE 
  # User defined linker options
)

# Add additional linker search directories
target_link_directories(${PROJECT_NAME} PRIVATE
  # Add additional linker search directories here
)

# Add additional linker libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
  # Add additional linker libraries here
)
