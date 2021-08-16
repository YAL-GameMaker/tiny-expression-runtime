/// @param code:string
function txr_compile(argument0) {
	if (txr_parse(argument0)) return undefined;
	if (txr_build()) return undefined;
	var out = txr_compile_list;
	ds_list_clear(out);
	var lbm = txr_compile_labels;
	ds_map_clear(lbm);
	if (txr_compile_expr(txr_build_node)) return undefined;
	//
	var k = ds_map_find_first(lbm);
	repeat (ds_map_size(lbm)) {
		var lbs = lbm[?k], lb;
		if (lbs[0] == undefined && array_length(lbs) > 1) {
			lb = lbs[1];
			txr_throw_at("Using undeclared label " + k, lb);
			return undefined;
		}
		var i = array_length(lbs);
		while (--i >= 1) {
			lb = lbs[i];
			lb[@2] = lbs[0];
		}
		k = ds_map_find_next(lbm, k);
	}
	//
	var n = ds_list_size(out);
	var arr = array_create(n);
	for (var i = 0; i < n; i++) arr[i] = out[|i];
	ds_list_clear(out);
	return arr;
}
