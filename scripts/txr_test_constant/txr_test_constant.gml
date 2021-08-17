function txr_test_constant() {
	txr_constant_add("_", undefined);
	txr_constant_add("const_str", "hi!");
	txr_constant_add("const_int", 4);
	txr_constant_add("const_real", 4.5);
	txr_constant_add("const_int64", 1<<62);
	txr_function_add("get_i1shl62", function() { return 1<<62 }, 0);
	txr_test_exec(/*gml*/@'
		assert(_, undefined, "_");
		assert(const_str, "hi!", "const_str");
		assert(const_int, 4, "const_int");
		assert(const_real, 4.5, "const_real");
		assert(const_int64, get_i1shl62(), "const_int64");
	');
}