/// @param actions
/// @param ?arguments:array|ds_map
function txr_exec() {
	var arr = argument[0];
	var argd = argument_count > 1 ? argument[1] : undefined;
	var th/*:txr_thread*/ = txr_thread_create(arr, argd);
	var result = undefined;
	switch (txr_thread_resume(th)) {
		case txr_thread_status.finished:
			txr_error = "";
			result = th[txr_thread.result];
			break;
		case txr_thread_status.error:
			txr_error = th[txr_thread.result];
			break;
		default:
			txr_error = "Thread paused execution but you are using txr_exec instead of txr_thread_resume";
			break;
	}
	txr_thread_destroy(th);
	return result;
}
