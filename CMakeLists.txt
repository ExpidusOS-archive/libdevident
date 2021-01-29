cmake_minimum_required(VERSION 3.19.3)
project(libdevident VERSION "0.1.0")

option(HARD_IDENT "Uses the internal device identification reporting feature, used for embedded devices." OFF)
option(FUNC_IDENT "Uses the function based device identification reporting feature, used for embedded devices." OFF)

if(HARD_IDENT)
	if(NOT "${IDENT_DEVICE_NAME}")
		set(IDENT_DEVICE_NAME "unknown")
	endif()
	if(NOT "${IDENT_DEVICE_REVISION}")
		set(IDENT_DEVICE_REVISION "0")
	endif()
	if(NOT "${IDENT_DEVICE_MANUFACTURER}")
		set(IDENT_DEVICE_MANUFACTURER "unknown")
	endif()
	if(NOT "${IDENT_DEVICE_TYPE}")
		set(IDENT_DEVICE_TYPE "UNKNOWN")
	endif()
elseif(NOT HARD_IDENT AND NOT FUNC_IDENT)
	set(FS_IDENT ON)
	include(CheckSymbolExists)

	check_symbol_exists(fopen "stdio.h" HAVE_FOPEN)
	if(NOT HAVE_FOPEN)
		message(FATAL_ERROR "fopen in stdio.h does not exist.")
	endif()
endif()

include(GNUInstallDirs)

configure_file("${PROJECT_SOURCE_DIR}/data/config.h.in" "${PROJECT_BINARY_DIR}/libdevident-config.h")

set(DEVIDENT_SOURCES "src/backend.c" "src/init.c")
include_directories("${PROJECT_SOURCE_DIR}/include" "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/jsmn")

# Shared library
add_library(devident-shared SHARED ${DEVIDENT_SOURCES})
set_target_properties(devident-shared PROPERTIES OUTPUT_NAME "devident")

# Static library
add_library(devident-static SHARED ${DEVIDENT_SOURCES})
set_target_properties(devident-static PROPERTIES OUTPUT_NAME "devident")
