/*
 * SPDX-FileCopyrightText: 2023 Kyunghwan Kwon <k@libmcu.org>
 *
 * SPDX-License-Identifier: MIT
 */

#include "libmcu/board.h"
#include "libmcu/timext.h"
#include "libmcu/gpio.h"

#include "pinmap.h"
#include "logging.h"

int main(void)
{
	board_init(); /* should be called very first. */

	logging_init(board_get_time_since_boot_ms);
	logging_stdout_backend_init();

	const board_reboot_reason_t reboot_reason = board_get_reboot_reason();
	info("[%s] %s %s", board_get_reboot_reason_string(reboot_reason),
			board_get_serial_number_string(),
			board_get_version_string());

	struct gpio *led = gpio_create(PINMAP_LED);
	gpio_enable(led);

	while (1) {
		gpio_set(led, gpio_get(led) ^ 1);
		sleep_ms(500);
	}

	return 0;
}
