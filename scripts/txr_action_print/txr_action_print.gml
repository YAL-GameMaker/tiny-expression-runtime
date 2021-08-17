function txr_action_print(argument0) {
	var q = argument0;
	var i, n;
	var s = "[" + txr_print_pos(q[1]) + "]";
	switch (q[0]) {
		case txr_action.number: return txr_sfmt("% number %", s, q[2]);
		case txr_action._string: return txr_sfmt("% string `%`", s, q[2]);
		case txr_action.binop: return txr_sfmt("% binop %", s, global.txr_op_names[q[2]]);
		case txr_action.discard: return s + " discard";
		case txr_action.dup: return s + " dup";
		case txr_action.call: return txr_sfmt("% %(%)", s, script_get_name(q[2]), q[3]);
		case txr_action.ident: return txr_sfmt("% get ident %", s, q[2]);
		case txr_action.set_ident: return txr_sfmt("% set ident %", s, q[2]);
		case txr_action.get_field: return txr_sfmt("% get field %", s, q[2]);
		case txr_action.set_field: return txr_sfmt("% set field %", s, q[2]);
		case txr_action.get_local: return txr_sfmt("% get local %", s, q[2]);
		case txr_action.set_local: return txr_sfmt("% set local %", s, q[2]);
		case txr_action.jump: return txr_sfmt("% jump %", s, q[2]);
		case txr_action.jump_if: return txr_sfmt("% jump_if %", s, q[2]);
		case txr_action.jump_unless: return txr_sfmt("% jump_unless %", s, q[2]);
		case txr_action._switch: return txr_sfmt("% switch_jump %", s, q[2]);
		case txr_action.get_array: return s + " get array";
		case txr_action.set_array: return s + " set array";
		case txr_action.array_literal: return txr_sfmt("% create array(%)", s, q[2]);
		case txr_action.value_call: return txr_sfmt("% value call(%)", s, q[2]);
		default:
			s = txr_sfmt("% A%", s, q[0]);
			n = array_length(q);
			for (i = 2; i < n; i++) s += " " + string(q[i]);
			return s;
	}
}
