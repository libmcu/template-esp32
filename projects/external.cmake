add_subdirectory(external/libmcu)

target_compile_definitions(libmcu PUBLIC
	_POSIX_THREADS
	_POSIX_C_SOURCE=200809L
	LIBMCU_NOINIT=__attribute__\(\(section\(\".rtc.data.libmcu\"\)\)\)
	METRICS_USER_DEFINES=\"${PROJECT_SOURCE_DIR}/include/metrics.def\"

	${APP_DEFS}
)
