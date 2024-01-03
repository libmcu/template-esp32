/*
 * SPDX-FileCopyrightText: 2023 Kyunghwan Kwon <k@mononn.com>
 *
 * SPDX-License-Identifier: MIT
 */

#include <stdio.h>

#include "libmcu/board.h"
#include "libmcu/logging.h"

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

static void logging_stdout_backend_init(void)
{
	static struct logging_backend log_console = {
		.write = logging_stdout_writer,
	};

	logging_add_backend(&log_console);
}

int main(void)
{
	board_init(); /* should be called very first. */
	logging_init(board_get_time_since_boot_ms);

	logging_stdout_backend_init();

	const board_reboot_reason_t reboot_reason = board_get_reboot_reason();

	info("[%s] %s %s", board_get_reboot_reason_string(reboot_reason),
			board_get_serial_number_string(),
			board_get_version_string());

	while (1) {
		/* hang */
	}
}
