function txr_test_value_call() {
	var a_func = function() { return "OK!" };
	txr_function_add("g_func", a_func, 0);
	with ({
		my_func: a_func,
		obj: { their_func: a_func },
		arr: [a_func],
	}) txr_test_exec(/*gml*/@'
		var ok = "OK!";
		assert(g_func(), ok, "g_func");
		assert(my_func(), ok, "my_func");
		assert(obj.their_func(), ok, "their_func");
		assert(arr[0](), ok, "arr_func");
	');
}