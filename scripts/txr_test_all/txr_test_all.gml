// NB! You shouldn't be importing unit tests into your project
function txr_test_all() {
	txr_function_add("assert", txr_test_assert, 3);
	//
	txr_test_constant();
	txr_test_struct();
	if (txr_value_calls) txr_test_value_call();
	show_debug_message(txr_exec_string(@'
		var who;
		return "hello, " + who + "!";
	', { who: "you" })); // hello, you!
	//
	show_debug_message("Tests OK!");
}
function txr_test_assert(_val, _want, _ctx) {
	if (_val != _want) {
		show_error(txr_sfmt("Assertion failed - got %, wanted % for %",_val,_want,_ctx), 1);
	} else {
		//show_debug_message(`$_ctx: OK`);
	}
}
function txr_test_exec(_code) {
	var result = txr_exec_string(_code);
	if (txr_error != "") show_error(txr_error, 1);
	return result;
}