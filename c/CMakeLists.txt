cmake_minimum_required(VERSION 3.20)

project(HelloWorld VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(project_warnings INTERFACE)
option(ENABLE_ASAN "Enable AddressSanitizer" OFF)

if(ENABLE_ASAN)
    target_compile_options(project_warnings INTERFACE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(project_warnings INTERFACE -fsanitize=address)
endif()

add_library(my-lib src/mylib.c)

add_executable(my-exe src/main.c)

target_link_libraries(my-lib PRIVATE project_warnings)
target_link_libraries(my-exe PRIVATE my-lib project_warnings)

target_compile_options(my-lib PRIVATE
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wformat=2
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Debug>:-g -O0 -DDEBUG>
)

target_include_directories(my-lib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported OUTPUT ipo_error)
if(ipo_supported AND CMAKE_BUILD_TYPE STREQUAL "Release")
    message(STATUS "IPO / LTO enabled")
    set_property(TARGET my-lib PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
    set_property(TARGET my-exe PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message(WARNING "IPO / LTO is not supported: ${ipo_error}")
endif()

include(GNUInstallDirs)

install(TARGETS my-lib my-exe
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

enable_testing()
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    add_executable(my_test tests/my_test.c)
    target_link_libraries(my_test PRIVATE my-lib project_warnings)

    add_test(NAME TestMyLib COMMAND my_test)
endif()
