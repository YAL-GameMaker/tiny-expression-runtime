/// @param txr_thread
/// @param label_name
/// @returns {bool} whether succeeded
function txr_thread_jump_push(th/*:txr_thread*/, label) {
	var arr = th[txr_thread.actions];
	if (arr == undefined) exit;
	var pos = -1;
	repeat (array_length(arr)) {
		var act = arr[++pos];
		if (act[0] == txr_action.label && act[2] == label) {
			ds_stack_push(th[txr_thread.jumpstack], th[txr_thread.pos]);
			th[@txr_thread.pos] = pos;
			if (th[txr_thread.status] == txr_thread_status.running) {
				th[@txr_thread.status] = txr_thread_status.jump;
			}
			return true;
		}
	}
	return false;
}
