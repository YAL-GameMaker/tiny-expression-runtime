/// @param node
var q = argument0;
var out = txr_compile_list;
switch (q[0]) {
	case txr_node.number: ds_list_add(out, [txr_action.number, q[1], q[2]]); break;
	case txr_node._string: ds_list_add(out, [txr_action._string, q[1], q[2]]); break;
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
    case txr_node.if_then: // -> <cond>; jump_unless(l1); <then>; l1:
        if (txr_compile_expr(q[2])) return true;
        var jmp = [txr_action.jump_unless, q[1], 0];
        ds_list_add(out, jmp);
        if (txr_compile_expr(q[3])) return true;
        jmp[@2] = ds_list_size(out);
        break;
    case txr_node.if_then_else: // -> <cond>; jump_unless(l1); <then>; goto l2; l1: <else>; l2:
        if (txr_compile_expr(q[2])) return true;
        var jmp_else = [txr_action.jump_unless, q[1], 0];
        ds_list_add(out, jmp_else);
        if (txr_compile_expr(q[3])) return true;
        var jmp_then = [txr_action.jump, q[1], 0];
        ds_list_add(out, jmp_then);
        jmp_else[@2] = ds_list_size(out);
        if (txr_compile_expr(q[4])) return true;
        jmp_then[@2] = ds_list_size(out);
        break;
    case txr_node.set:
        if (txr_compile_expr(q[3])) return true;
        var _expr = q[2];
        switch (_expr[0]) {
            case txr_node.ident:
                ds_list_add(out, [txr_action.set_ident, q[1], _expr[2]]);
                break;
            default: return txr_throw_at("Expression is not settable", _expr);
        }
        break;
	default: return txr_throw_at("Cannot compile node type " + string(q[0]), q);
}
return false;