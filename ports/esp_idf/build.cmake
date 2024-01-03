set(COMPONENTS_USED
	freertos
	esptool_py
	bt
	esp-tls
	esp_http_server
	esp_http_client
	esp_https_ota
	app_update
)

if ($ENV{IDF_VERSION} VERSION_GREATER_EQUAL "5.0.0")
	list(APPEND COMPONENTS_USED esp_adc)
else()
	list(APPEND COMPONENTS_USED esp_adc_cal)
endif()

idf_build_process(${IDF_TARGET}
	COMPONENTS
		${COMPONENTS_USED}
	SDKCONFIG_DEFAULTS
		"${CMAKE_CURRENT_LIST_DIR}/sdkconfig.defaults"
	BUILD_DIR
		${CMAKE_CURRENT_BINARY_DIR}
)

set(mapfile "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.map")
# project_description.json metadata file used for the flash and the monitor of
# idf.py to get the project information.
set(PROJECT_EXECUTABLE ${CMAKE_PROJECT_NAME}.elf)
set(PROJECT_BIN ${CMAKE_PROJECT_NAME}.bin)
set(build_components_json "[]")
set(build_component_paths_json "[]")
configure_file("${IDF_PATH}/tools/cmake/project_description.json.in"
	"${CMAKE_CURRENT_BINARY_DIR}/project_description.json")

add_executable(${PROJECT_EXECUTABLE}
	${CMAKE_SOURCE_DIR}/src/main.c
)

target_compile_definitions(${PROJECT_EXECUTABLE}
	PRIVATE
		ESP_PLATFORM=1
		xPortIsInsideInterrupt=xPortInIsrContext
)
target_include_directories(${PROJECT_EXECUTABLE}
	PRIVATE
		$ENV{IDF_PATH}/components/freertos/FreeRTOS-Kernel/include/freertos
		$ENV{IDF_PATH}/components/freertos/include/freertos
		${CMAKE_CURRENT_LIST_DIR}
)

target_link_libraries(${PROJECT_EXECUTABLE}
	idf::freertos
	idf::spi_flash
	idf::nvs_flash
	idf::driver
	idf::pthread
	idf::esp_http_server
	idf::esp_http_client
	idf::esp_https_ota
	idf::app_update

	-Wl,--cref
	-Wl,--Map=\"${mapfile}\"
)
if ($ENV{IDF_VERSION} VERSION_GREATER_EQUAL "5.0.0")
target_link_libraries(${PROJECT_EXECUTABLE} idf::esp_adc)
else()
target_link_libraries(${PROJECT_EXECUTABLE} idf::esp_adc_cal)
endif()

set(idf_size ${python} $ENV{IDF_PATH}/tools/idf_size.py)
add_custom_target(size DEPENDS ${mapfile} COMMAND ${idf_size} ${mapfile})
add_custom_target(size-files DEPENDS ${mapfile} COMMAND ${idf_size} --files ${mapfile})
add_custom_target(size-components DEPENDS ${mapfile} COMMAND ${idf_size} --archives ${mapfile})

# Attach additional targets to the executable file for flashing,
# linker script generation, partition_table generation, etc.
idf_build_executable(${PROJECT_EXECUTABLE})
