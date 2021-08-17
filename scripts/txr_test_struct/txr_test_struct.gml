function txr_test_struct() {
	var q = txr_test_exec(/*gml*/@'
		var q = { a: 1, b: 2, c: 3 };
		assert(q.a, 1, "q.a");
		assert(q.b, 2, "q.b");
		assert(q.c, 3, "q.c");
		return q;
	')
	txr_test_assert(variable_struct_names_count(q), 3, "q.count");
}