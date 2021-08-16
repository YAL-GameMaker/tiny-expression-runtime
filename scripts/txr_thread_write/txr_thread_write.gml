/// @param txr_thread
/// @param buffer
function txr_thread_write(argument0, argument1) {
	var th/*:txr_thread*/ = argument0, b/*:Buffer*/ = argument1;
	//
	buffer_write(b, buffer_u8, th[txr_thread.status]);
	buffer_write(b, buffer_s32, th[txr_thread.pos]);
	txr_value_write(th[txr_thread.result], b);
	//show_debug_message(txr_sfmt("stack@%", b.tell()));
	var s = th[txr_thread.stack];
	var n = ds_stack_size(s), i;
	var w = array_create(n), v;
	buffer_write(b, buffer_u32, n);
	for (i = 0; i < n; i++) w[i] = ds_stack_pop(s);
	while (--i >= 0) {
		v = w[i];
		txr_value_write(v, b);
		ds_stack_push(s, v);
	}
	//
	s = th[txr_thread.jumpstack];
	n = ds_stack_size(s);
	w = array_create(n);
	buffer_write(b, buffer_u32, n);
	for (i = 0; i < n; i++) w[i] = ds_stack_pop(s);
	while (--i >= 0) {
		v = w[i];
		buffer_write(b, buffer_s32, v);
		ds_stack_push(s, v);
	}
	//show_debug_message(txr_sfmt("locals@%", b.tell()));
	var m = th[txr_thread.locals];
	n = ds_map_size(m);
	buffer_write(b, buffer_u32, n);
	v = ds_map_find_first(m);
	repeat (n) {
		txr_value_write(v, b);
		txr_value_write(m[?v], b);
		v = ds_map_find_next(m, v);
	}
	//show_debug_message(txr_sfmt("actions@%", b.tell()));
	w = th[txr_thread.actions];
	n = array_length(w);
	buffer_write(b, buffer_u32, n);
	for (i = 0; i < n; i++) {
		txr_action_write(w[i], b);
	}
}
