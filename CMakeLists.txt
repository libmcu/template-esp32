cmake_minimum_required(VERSION 3.16)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
	cmake_policy(SET CMP0135 NEW)
endif()

if (NOT DEFINED IDF_TARGET)
	set(IDF_TARGET esp32s3)
endif()
set(CMAKE_TOOLCHAIN_FILE $ENV{IDF_PATH}/tools/cmake/toolchain-${IDF_TARGET}.cmake)

project(template)

include($ENV{IDF_PATH}/tools/cmake/idf.cmake)
include(${CMAKE_SOURCE_DIR}/ports/esp_idf/build.cmake)
