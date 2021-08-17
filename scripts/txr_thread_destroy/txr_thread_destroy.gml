function txr_thread_destroy(th/*:txr_thread*/) {
	if (th[txr_thread.actions] != undefined) {
		ds_stack_destroy(th[txr_thread.stack]);
		ds_stack_destroy(th[txr_thread.jumpstack]);
		th[@txr_thread.locals] = undefined;
		th[@txr_thread.actions] = undefined;
		th[@txr_thread.status] = txr_thread_status.none;
	}
}
