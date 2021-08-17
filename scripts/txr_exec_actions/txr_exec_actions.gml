/// @param {array} actions
/// @param {array|struct|ds_map} ?_args
function txr_exec_actions(_actions, _args) {
	var th/*:txr_thread*/ = txr_thread_create(_actions, _args);
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
