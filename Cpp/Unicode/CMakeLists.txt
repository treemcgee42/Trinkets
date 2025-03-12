cmake_minimum_required(VERSION 3.10)
project(Unicode CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_library(unicode SHARED Unicode.cpp
                           Codepoints.cpp)
target_include_directories(unicode PUBLIC ${CMAKE_SOURCE_DIR})

add_executable(test_basic Tests/Basic.cpp)
target_include_directories(test_basic PUBLIC ${CMAKE_SOURCE_DIR})
target_link_libraries(test_basic PRIVATE unicode)

install(FILES Unicode.h DESTINATION ${CMAKE_SOURCE_DIR}/../Include/Unicode)
install(TARGETS unicode
    LIBRARY DESTINATION ${CMAKE_SOURCE_DIR}/../Lib
    RUNTIME DESTINATION ${CMAKE_SOURCE_DIR}/../Lib
)

# add_custom_target(test
#     COMMAND test_basic
#     DEPENDS test_basic
#     WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
# )
