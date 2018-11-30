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
	case txr_node.block:
	    var nodes = q[2];
	    var n = array_length_1d(nodes);
	    for (var i = 0; i < n; i++) {
	        if (txr_compile_expr(nodes[i])) return true;
	    }
	    break;
    case txr_node.ret:
		if (txr_compile_expr(q[2])) return true;
        ds_list_add(out, [txr_action.ret, q[1]]);
		break;
    case txr_node.discard:
        if (txr_compile_expr(q[2])) return true;
        ds_list_add(out, [txr_action.discard, q[1]]);
        break;
	default: return txr_throw_at("Cannot compile node type " + string(q[0]), q);
}
return false;