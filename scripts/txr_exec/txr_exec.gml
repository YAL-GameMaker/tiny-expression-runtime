/// @param actions
var arr = argument0;
var len = array_length_1d(arr);
var pos = 0;
var stack = ds_stack_create();
while (pos < len) {
	var q = arr[pos++];
	switch (q[0]) {
		case txr_action.number: ds_stack_push(stack, q[2]); break;
		case txr_action.unop: ds_stack_push(stack, -ds_stack_pop(stack)); break;
		case txr_action.binop:
			var b = ds_stack_pop(stack);
			var a = ds_stack_pop(stack);
			switch (q[2]) {
				case txr_op.add: a += b; break;
				case txr_op.sub: a -= b; break;
				case txr_op.mul: a *= b; break;
				case txr_op.fdiv: a /= b; break;
				case txr_op.fmod: if (b != 0) a %= b; else a = 0; break;
				case txr_op.idiv: if (b != 0) a = a div b; else a = 0; break;
				default: return txr_exec_exit("Can't apply operator " + string(q[2]), q, stack);
			}
			ds_stack_push(stack, a);
			break;
		case txr_action.ident:
			var v = variable_instance_get(id, q[2]);
			if (is_real(v) || is_int64(v) || is_bool(v) || is_int32(v)) {
				ds_stack_push(stack, v);
			} else return txr_exec_exit("Variable `" + q[2] + "` is not a number", q, stack);
			break;
		case txr_action.call:
			var args = global.txr_exec_args;
			ds_list_clear(args);
			var i = q[3], v;
			while (--i >= 0) args[|i] = ds_stack_pop(stack);
			txr_function_error = undefined;
			switch (q[3]) {
				case 0: v = script_execute(q[2]); break;
				case 1: v = script_execute(q[2], args[|0]); break;
				case 2: v = script_execute(q[2], args[|0], args[|1]); break;
				case 3: v = script_execute(q[2], args[|0], args[|1], args[|2]); break;
				// and so on
				default: return txr_exec_exit("Too many arguments (" + string(q[3]) + ")", q, stack);
			}
			if (txr_function_error == undefined) {
				ds_stack_push(stack, v);
			} else return txr_exec_exit(txr_function_error, q, stack);
			break;
		default: return txr_exec_exit("Can't run action " + string(q[0]), q, stack);
	}
}
var r = ds_stack_pop(stack);
ds_stack_destroy(stack);
txr_error = "";
return r;