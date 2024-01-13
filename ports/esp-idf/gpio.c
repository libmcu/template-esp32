/*
 * SPDX-FileCopyrightText: 2023 Kyunghwan Kwon <k@libmcu.org>
 *
 * SPDX-License-Identifier: MIT
 */

#include "libmcu/gpio.h"
#include "libmcu/compiler.h"

#include <errno.h>

#include "driver/gpio.h"
#include "pinmap.h"

struct gpio {
	struct gpio_api api;

	uint16_t pin;
	gpio_callback_t callback;
	void *callback_ctx;
};

static void set_output(uint16_t pin)
{
	gpio_config_t io_conf = {
		.intr_type = GPIO_INTR_DISABLE,
		.mode = GPIO_MODE_INPUT_OUTPUT,
		.pin_bit_mask = (1ULL << pin),
	};
	gpio_config(&io_conf);
}

static int enable_gpio(struct gpio *self)
{
	switch (self->pin) {
	case PINMAP_LED:
		set_output(self->pin);
		break;
	default:
		return -ERANGE;
	}

	return 0;
}

static int disable_gpio(struct gpio *self)
{
	unused(self);
	return 0;
}

static int set_gpio(struct gpio *self, int value)
{
	return gpio_set_level(self->pin, (uint32_t)value);
}

static int get_gpio(struct gpio *self)
{
	return gpio_get_level(self->pin);
}

static int register_callback(struct gpio *self,
		gpio_callback_t cb, void *cb_ctx)
{
	self->callback = cb;
	self->callback_ctx = cb_ctx;
	return 0;
}

struct gpio *gpio_create(uint16_t pin)
{
	static struct gpio led;

	struct gpio *p;

	switch (pin) {
	case PINMAP_LED:
		p = &led;
		break;
	default:
		return NULL;
	}

	p->pin = pin;

	p->api = (struct gpio_api) {
		.enable = enable_gpio,
		.disable = disable_gpio,
		.set = set_gpio,
		.get = get_gpio,
		.register_callback = register_callback,
	};

	return p;
}

void gpio_delete(struct gpio *self)
{
	unused(self);
}
