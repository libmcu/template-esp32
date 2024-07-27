/*
 * SPDX-FileCopyrightText: 2023 Kyunghwan Kwon <k@libmcu.org>
 *
 * SPDX-License-Identifier: MIT
 */

#include "logger.h"
#include <stdio.h>
#include "libmcu/board.h"

static size_t logger_writer(const void *data, size_t size)
{
	unused(size);
	static char buf[LOGGING_MESSAGE_MAXLEN];
	size_t len = logging_stringify(buf, sizeof(buf)-2, data);

	buf[len++] = '\n';
	buf[len] = '\0';

	const size_t rc = fwrite(buf, len, 1, stdout);

	return rc == 0? len : 0;
}

static void initialize_backend_stdout(void)
{
	static struct logging_backend log_console = {
		.write = logger_writer,
	};

	logging_add_backend(&log_console);
}

void logger_init(void)
{
	logging_init(board_get_time_since_boot_ms);
	initialize_backend_stdout();
}
