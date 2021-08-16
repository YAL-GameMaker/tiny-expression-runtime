function txr_build_loop_body() {
	var could_break = txr_build_can_break;
	var could_continue = txr_build_can_continue;
	txr_build_can_break = true;
	txr_build_can_continue = true;
	var trouble = txr_build_stat();
	txr_build_can_break = could_break;
	txr_build_can_continue = could_continue;
	return trouble;
}
