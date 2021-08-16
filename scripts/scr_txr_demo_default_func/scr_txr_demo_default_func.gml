function scr_txr_demo_default_func() {
	// This is used to resolve unknown functions
	var pg = global.extra_functions[?argument[0]];
	if (pg == undefined) {
		txr_function_error = string(argument[0]) + " is not a known function or script.";
		exit;
	}
	var i = argument_count - 1;
	var args = array_create(i);
	while (--i >= 0) args[i] = argument[i + 1];
	return txr_exec(pg, args);
}
