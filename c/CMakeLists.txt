cmake_minimum_required(VERSION 3.25)

project(hello VERSION 0.1.0 DESCRIPTION "A small C project" LANGUAGES C)

include(CTest)
include(GNUInstallDirs)

option(
    ENABLE_SANITIZERS
    "Build with AddressSanitizer and UndefinedBehaviorSanitizer"
    OFF
)

add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE c_std_17)
target_compile_options(
    project_options
    INTERFACE -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wformat=2
)

if(ENABLE_SANITIZERS)
    target_compile_options(
        project_options
        INTERFACE
            -fsanitize=address,undefined
            -fno-omit-frame-pointer
            -fno-sanitize-recover=all
    )
    target_link_options(project_options INTERFACE -fsanitize=address,undefined)
endif()

add_library(greeting src/greeting.c)
target_link_libraries(greeting PRIVATE project_options)
target_include_directories(
    greeting
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

add_executable(hello src/main.c)
target_link_libraries(hello PRIVATE greeting project_options)

install(
    TARGETS hello greeting
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(DIRECTORY include/ TYPE INCLUDE)

if(PROJECT_IS_TOP_LEVEL AND BUILD_TESTING)
    add_executable(greeting_test tests/greeting_test.c)
    target_link_libraries(greeting_test PRIVATE greeting project_options)
    add_test(NAME greeting_test COMMAND greeting_test)
endif()
