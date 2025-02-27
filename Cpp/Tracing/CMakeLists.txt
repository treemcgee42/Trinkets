cmake_minimum_required(VERSION 3.10)
project(MyProject C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)

add_library(tracing SHARED Tracing.c)
target_include_directories(tracing PUBLIC ${CMAKE_SOURCE_DIR})

add_executable(test_basic Tests/Basic.c)
target_include_directories(test_basic PUBLIC ${CMAKE_SOURCE_DIR})
target_link_libraries(test_basic PRIVATE tracing)

add_custom_target(test
    COMMAND test_basic
    DEPENDS test_basic
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
