/// @param node
var q = argument0;
var out = txr_compile_list;
switch (q[0]) {
	case txr_node.number: ds_list_add(out, [txr_action.number, q[1], q[2]]); break;
	case txr_node.ident: ds_list_add(out, [txr_action.ident, q[1], q[2]]); break;
	case txr_node.unop:
		if (txr_compile_expr(q[3])) return true;
		ds_list_add(out, [txr_action.unop, q[1], q[2]]);
		break;
	case txr_node.binop:
		if (txr_compile_expr(q[3])) return true;
		if (txr_compile_expr(q[4])) return true;
		ds_list_add(out, [txr_action.binop, q[1], q[2]]);
		break;
	case txr_node.call:
		var args = q[3];
		var argc = array_length_1d(args);
		for (var i = 0; i < argc; i++) {
			if (txr_compile_expr(args[i])) return true;
		}
		ds_list_add(out, [txr_action.call, q[1], q[2], argc]);
		break;
	default: return txr_throw_at("Cannot compile node type " + string(q[0]), q);
}
return false;