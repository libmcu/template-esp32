/*
 * SPDX-FileCopyrightText: 2023 Kyunghwan Kwon <k@mononn.com>
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef LOGGING_H
#define LOGGING_H

#if defined(__cplusplus)
extern "C" {
#endif

#include "libmcu/logging.h"

void logging_stdout_backend_init(void);

#if defined(__cplusplus)
}
#endif

#endif /* LOGGING_H */
