#include <os/log.h>
#include <os/activity.h>

// Created a wrapper for os_log to allow we call the macro in rust code
void _os_log_with_type(os_log_t log, os_log_type_t type, const char* message);

