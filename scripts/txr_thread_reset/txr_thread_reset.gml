/// @param txr_thread
/// @param {array|struct|ds_map<string, any>} ?arguments
function txr_thread_reset(th/*:txr_thread*/, _args) {
	th[@txr_thread.pos] = 0;
	ds_stack_clear(th[txr_thread.stack]);
	ds_stack_clear(th[txr_thread.jumpstack]);
	th[@txr_thread.locals] = {};
	th[@txr_thread.result] = undefined;
	th[@txr_thread.status] = txr_thread_status.running;
	if (_args != undefined) txr_thread_set_args(th, _args);
}