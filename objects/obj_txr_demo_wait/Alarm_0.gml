if (txr_thread_resume(thread) == txr_thread_status.error) {
    show_debug_message(thread[txr_thread.result]);
}
instance_destroy();