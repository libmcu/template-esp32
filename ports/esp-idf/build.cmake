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

AUX_SOURCE_DIRECTORY(${CMAKE_CURRENT_LIST_DIR} PORT_SRCS)

target_include_directories(libmcu PUBLIC
	${CMAKE_SOURCE_DIR}/external/libmcu/modules/common/include/libmcu/posix)
target_compile_definitions(libmcu PRIVATE timer_start=libmcu_timer_start)

set(LIBMCU_ROOT ${PROJECT_SOURCE_DIR}/external/libmcu)
if ($ENV{IDF_VERSION} VERSION_LESS "5.1.0")
	list(APPEND PORT_SRCS ${LIBMCU_ROOT}/ports/freertos/semaphore.c)
endif()

add_executable(${PROJECT_EXECUTABLE}
	${APP_SRCS}
	${PORT_SRCS}

	${LIBMCU_ROOT}/ports/esp-idf/board.c
	${LIBMCU_ROOT}/ports/esp-idf/actor.c
	${LIBMCU_ROOT}/ports/esp-idf/pthread.c
	${LIBMCU_ROOT}/ports/esp-idf/wifi.c
	${LIBMCU_ROOT}/ports/esp-idf/metrics.c
	${LIBMCU_ROOT}/ports/esp-idf/nvs_kvstore.c
	${LIBMCU_ROOT}/ports/freertos/timext.c
	${LIBMCU_ROOT}/ports/freertos/hooks.c
	${LIBMCU_ROOT}/ports/posix/logging.c
	${LIBMCU_ROOT}/ports/posix/button.c
)

target_compile_definitions(${PROJECT_EXECUTABLE}
	PRIVATE
		${APP_DEFS}

		ESP_PLATFORM=1
		xPortIsInsideInterrupt=xPortInIsrContext
)
target_include_directories(${PROJECT_EXECUTABLE}
	PRIVATE
		${APP_INCS}

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
	idf::esp_timer
	idf::esp_wifi

	libmcu

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
