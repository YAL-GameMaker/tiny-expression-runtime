// NB! You shouldn't be importing unit tests into your project
function test_txr() {
	txr_function_add("assert", function(_val, _want, _ctx) {
		if (_val != _want) {
			show_error(txr_sfmt("Assertion failed - got %, wanted % for %",_val,_want,_ctx), 1);
		} else {
			//show_debug_message(`$_ctx: OK`);
		}
	}, 3);
	//
	test_txr_const();
	if (txr_value_calls) test_txr_value_calls();
	show_debug_message(txr_exec_string(@'
		var who;
		return "hello, " + who + "!";
	', { who: "you" })); // hello, you!
	//
	show_debug_message("Tests OK!");
}
function test_exec(_code) {
	txr_exec_string(_code);
	if (txr_error != "") show_error(txr_error, 1);
}