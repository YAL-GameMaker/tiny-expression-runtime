function txr_thread_destroy(argument0) {
	var th/*:txr_thread*/ = argument0;
	if (th[txr_thread.actions] != undefined) {
		ds_stack_destroy(th[txr_thread.stack]);
		ds_stack_destroy(th[txr_thread.jumpstack]);
		ds_map_destroy(th[txr_thread.locals]);
		th[@txr_thread.actions] = undefined;
		th[@txr_thread.status] = txr_thread_status.none;
	}
}
