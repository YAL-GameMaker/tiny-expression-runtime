/// dlg(prompt, ...options)
function scr_txr_demo_dlg() {
	var th = txr_thread_yield();
	if (th == undefined) exit;
	//
	var thc/*:txr_thread*/ = txr_thread_current;
	var actions = thc[txr_thread.actions]
	var action = actions[thc[txr_thread.pos] - 1];
	show_debug_message(txr_sfmt("dialog called from %", txr_print_pos(action[1])));
	//
	with (instance_create_depth(0, 0, 0, obj_txr_demo_dialog)) {
		thread = th;
		prompt = argument[0];
		var n = argument_count - 1;
		options = array_create(n);
		option_heights = array_create(n);
		for (var i = 0; i < n; i++) options[i] = argument[i + 1];
	}
}
