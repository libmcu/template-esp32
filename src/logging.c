/*
 * SPDX-FileCopyrightText: 2023 Kyunghwan Kwon <k@mononn.com>
 *
 * SPDX-License-Identifier: MIT
 */

#include "logging.h"
#include <stdio.h>

static size_t logging_stdout_writer(const void *data, size_t size)
{
	unused(size);
	static char buf[LOGGING_MESSAGE_MAXLEN];
	size_t len = logging_stringify(buf, sizeof(buf)-1, data);

	buf[len++] = '\n';
	buf[len] = '\0';

	const size_t rc = fwrite(buf, len, 1, stdout);

	return rc == 0? len : 0;
}

void logging_stdout_backend_init(void)
{
	static struct logging_backend log_console = {
		.write = logging_stdout_writer,
	};

	logging_add_backend(&log_console);
}
