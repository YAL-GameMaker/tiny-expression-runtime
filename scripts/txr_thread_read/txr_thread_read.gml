/// @param buffer
/// @return thread
function txr_thread_read(argument0) {
	var b/*:Buffer*/ = argument0;
	var th/*:txr_thread*/ = array_create(txr_thread.sizeof);
	th[@txr_thread.status] = buffer_read(b, buffer_u8);
	th[@txr_thread.pos] = buffer_read(b, buffer_s32);
	th[@txr_thread.result] = txr_value_read(b);
	//show_debug_message(txr_sfmt("stack@%", b.tell()));
	var s = ds_stack_create();
	repeat (buffer_read(b, buffer_u32)) ds_stack_push(s, txr_value_read(b));
	th[@txr_thread.stack] = s;
	//
	s = ds_stack_create();
	repeat (buffer_read(b, buffer_u32)) ds_stack_push(s, buffer_read(b, buffer_s32));
	th[@txr_thread.jumpstack] = s;
	//show_debug_message(txr_sfmt("locals@%", b.tell()));
	var m = ds_map_create();
	n = buffer_read(b, buffer_u32);
	repeat (n) {
		var v = txr_value_read(b);
		m[?v] = txr_value_read(b);
	}
	th[@txr_thread.locals] = m;
	//show_debug_message(txr_sfmt("actions@%", b.tell()));
	var n = buffer_read(b, buffer_u32);
	var w = array_create(n);
	for (var i = 0; i < n; i++) {
		w[i] = txr_action_read(b);
	}
	th[@txr_thread.actions] = w;
	//
	return th;
}
