/// @param ...values
function scr_txr_demo_array() {
	var n = argument_count;
	var arr = array_create(n);
	for (var i = 0; i < n; i++) {
		arr[i] = argument[i];
	}
	return arr;
}
