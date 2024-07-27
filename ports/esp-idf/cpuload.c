/*
 * SPDX-FileCopyrightText: 2024 Kyunghwan Kwon <k@libmcu.org>
 *
 * SPDX-License-Identifier: MIT
 */

#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define CPULOAD_CALC_INTERVAL_MS	1000

static struct cpuload {
	uint32_t idle_time_elapsed;
	uint32_t running_time_elapsed;
	TaskHandle_t prev_task;
	uint8_t cpuload;
} cores[SOC_CPU_CORES_NUM];

void on_task_switch_in(void)
{
	static uint64_t t0;
	static uint64_t sum_elapsed;

	uint64_t t1 = esp_timer_get_time(); /* in microseconds */
	uint32_t elapsed = t1 - t0;

	/* NOTE: count at least 1 even if the task has run for much shorter time
	 * as microsecond unit timer used here. For fine granularity, introduce
	 * more high-resolution timer. */
	if (elapsed == 0) {
		elapsed = 1;
	}

	TaskHandle_t current = xTaskGetCurrentTaskHandle();
	struct cpuload *core = &cores[xPortGetCoreID()];

	if (current == xTaskGetIdleTaskHandle()) {
		if (current == core->prev_task) { /* idle to idle */
			core->idle_time_elapsed += elapsed;
		} else { /* active to idle */
			core->running_time_elapsed += elapsed;
		}
	} else {
		if (current == core->prev_task) { /* active to active */
			core->running_time_elapsed += elapsed;
		} else { /* idle to active */
			core->idle_time_elapsed += elapsed;
		}
	}

	sum_elapsed += elapsed;
	core->cpuload = (uint8_t)(core->running_time_elapsed * 100 /
			(core->running_time_elapsed + core->idle_time_elapsed));

	if (sum_elapsed >= CPULOAD_CALC_INTERVAL_MS) {
		core->running_time_elapsed = core->idle_time_elapsed = 0;
		sum_elapsed = 0;
	}

	t0 = t1;
	core->prev_task = current;
}

uint8_t board_cpuload(int core_id)
{
	return cores[core_id].cpuload;
}
