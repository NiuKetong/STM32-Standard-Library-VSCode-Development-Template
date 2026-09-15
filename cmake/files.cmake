# Add sources to executable/library
target_sources(${PROJECT_NAME} PRIVATE
    Src/User/main.c
    Src/User/startup_stm32f103xx.S
    Src/User/syscall.c
    Src/User/sysmem.c
    Src/Hardware/GPIO.c
    Src/System/Delay.c
    Src/Hardware/OLED.c
)

configure_file(stm32f103x8_flash.ld "${CMAKE_CURRENT_BINARY_DIR}" COPYONLY)

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/stm32f103x8_flash.ld")
