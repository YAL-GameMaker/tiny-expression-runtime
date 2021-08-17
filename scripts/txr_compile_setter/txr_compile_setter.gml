/// @param node
/// @returns {bool} whether encountered an error
function txr_compile_setter(q) {
	var out = txr_compile_list;
	switch (q[0]) {
		case txr_node.ident:
			var s = q[2];
			/*// example of global_some -> global.some
			if (string_length(s) > 7 && string_copy(s, 1, 7) == "global_") {
				out.add([txr_action._string, q[1], string_delete(s, 1, 7)]);
				out.add([txr_action.call, q[1], scr_txr_demo_global_set, 2]);
			} else
			//*/
			if (ds_map_exists(global.txr_constant_map, s)) {
				return txr_throw_at("Constants are not settable", q);
			} else if (ds_map_exists(txr_build_locals, s)) {
				ds_list_add(out, [txr_action.set_local, q[1], s]);
			} else {
				ds_list_add(out, [txr_action.set_ident, q[1], s]);
			}
			return false;
		case txr_node.field:
			if (txr_compile_expr(q[2])) return true;
			ds_list_add(out, [txr_action.set_field, q[1], q[3]]);
			return false;
		case txr_node.array_access:
			if (txr_compile_expr(q[2])) return true;
			if (txr_compile_expr(q[3])) return true;
			ds_list_add(out, [txr_action.set_array, q[1]]);
			return false;
		default: return txr_throw_at("Expression is not settable", q);
	}
}
