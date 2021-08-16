function scr_txr_demo_trace() {
	var r = scr_txr_demo_af(argument[0]);
	for (var i = 1; i < argument_count; i++) {
		r += " " + scr_txr_demo_af(argument[i]);
	}
	show_debug_message(r);
}
