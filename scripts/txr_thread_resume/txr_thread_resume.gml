/// @param txr_thread
/// @param ?yield_value - only used if resuming a thread after a yield
/// @return txr_thread_status
function txr_thread_resume() {
	var th/*:txr_thread*/ = argument[0];
	var val = argument_count > 1 ? argument[1] : undefined;
	var arr = th[txr_thread.actions];
	if (arr == undefined) exit;
	var _previous = txr_thread_current;
	txr_thread_current = th;
	var stack/*:Stack*/ = th[txr_thread.stack];
	switch (th[txr_thread.status]) {
		case txr_thread_status.error:
		case txr_thread_status.finished:
			return th[txr_thread.status];
		case txr_thread_status.yield:
			ds_stack_push(stack, val);
			break;
	}
	th[@txr_thread.result] = val;
	var pos = th[txr_thread.pos];
	var len = array_length(arr);
	var locals = th[txr_thread.locals];
	var q = undefined; 
	var halt = undefined;
	th[@txr_thread.status] = txr_thread_status.running;
	while (pos < len) {
		if (halt == txr_thread_status.jump) {
			halt = undefined;
			pos = th[txr_thread.pos];
		} else if (halt != undefined) break;
		q = arr[pos++];
		switch (q[0]) {
			case txr_action.label: break;
			case txr_action.number: ds_stack_push(stack, q[2]); break;
			case txr_action._string: ds_stack_push(stack, q[2]); break;
			case txr_action.unop:
				var v = ds_stack_pop(stack);
				if (q[2] == txr_unop.invert) {
					ds_stack_push(stack, v ? false : true);
				} else if (is_string(v)) {
					halt = "Can't apply unary - to a string";
					continue;
				} else ds_stack_push(stack, -v);
				break;
			case txr_action.binop:
				var b = ds_stack_pop(stack);
				var a = ds_stack_pop(stack);
				if (q[2] == txr_op.eq) {
					a = (a == b);
				}
				else if (q[2] == txr_op.ne) {
					a = (a != b);
				}
				else if (is_string(a) || is_string(b)) {
					if (q[2] == txr_op.add) {
						if (!is_string(a)) a = string(a);
						if (!is_string(b)) b = string(b);
						a += b;
					} else {
						halt = txr_sfmt("Can't apply % to `%`[%] and `%`[%]",
							global.txr_op_names[q[2]], a, typeof(a), b, typeof(b));
						continue;
					}
				}
				else if (txr_is_number(a) && txr_is_number(b)) switch (q[2]) {
					case txr_op.add: a += b; break;
					case txr_op.sub: a -= b; break;
					case txr_op.mul: a *= b; break;
					case txr_op.fdiv: a /= b; break;
					case txr_op.fmod: if (b != 0) a %= b; else a = 0; break;
					case txr_op.idiv: if (b != 0) a = a div b; else a = 0; break;
					case txr_op.shl: a = (a << b); break;
					case txr_op.shr: a = (a >> b); break;
					case txr_op.iand: a &= b; break;
					case txr_op.ior: a |= b; break;
					case txr_op.ixor: a ^= b; break;
					case txr_op.lt: a = (a < b); break;
					case txr_op.le: a = (a <= b); break;
					case txr_op.gt: a = (a > b); break;
					case txr_op.ge: a = (a >= b); break;
					default:
						halt = txr_sfmt("Can't apply %", global.txr_op_names[q[2]]);
						continue;
				} else {
					halt = txr_sfmt("Can't apply % to `%`[%] and `%`[%]",
						global.txr_op_names[q[2]], a, typeof(a), b, typeof(b));
					continue;
				}
				ds_stack_push(stack, a);
				break;
			case txr_action.ident:
				var v = variable_instance_get(id, q[2]);
				ds_stack_push(stack, v);
				break;
			case txr_action.set_ident:
				variable_instance_set(id, q[2], ds_stack_pop(stack));
				break;
			case txr_action.get_field:
				var v = ds_stack_pop(stack);
				v = variable_instance_get(v, q[2]);
				ds_stack_push(stack, v);
				break;
			case txr_action.set_field:
				var v = ds_stack_pop(stack);
				variable_instance_set(v, q[2], ds_stack_pop(stack));
				break;
			case txr_action.get_local:
				ds_stack_push(stack, locals[?q[2]]);
				break;
			case txr_action.set_local:
				locals[?q[2]] = ds_stack_pop(stack);
				break;
			case txr_action.call:
				var args = global.txr_exec_args;
				ds_list_clear(args);
				var i = q[3], v;
				while (--i >= 0) args[|i] = ds_stack_pop(stack);
				txr_function_error = undefined;
				th[@txr_thread.pos] = pos;
				switch (q[3]) {
					case  0: v = script_execute(q[2]); break;
					case  1: v = script_execute(q[2], args[|0]); break;
					case  2: v = script_execute(q[2], args[|0], args[|1]); break;
					case  3: v = script_execute(q[2], args[|0], args[|1], args[|2]); break;
					case  4: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3]); break;
					case  5: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4]); break;
					case  6: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5]); break;
					case  7: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6]); break;
					case  8: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7]); break;
					case  9: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8]); break;
					case 10: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9]); break;
					case 11: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9], args[|10]); break;
					case 12: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9], args[|10], args[|11]); break;
					case 13: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9], args[|10], args[|11], args[|12]); break;
					case 14: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9], args[|10], args[|11], args[|12], args[|13]); break;
					case 15: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9], args[|10], args[|11], args[|12], args[|13], args[|14]); break;
					case 16: v = script_execute(q[2], args[|0], args[|1], args[|2], args[|3], args[|4], args[|5], args[|6], args[|7], args[|8], args[|9], args[|10], args[|11], args[|12], args[|13], args[|14], args[|15]); break;
					// and so on
					default:
						halt = txr_sfmt("Too many arguments (%)", q[3]);
						continue;
				}
				// hit an error?:
				halt = txr_function_error;
				if (halt != undefined) continue;
				// thread yielded/destroyed?:
				if (th[txr_thread.status] != txr_thread_status.running) {
					halt = th[txr_thread.status];
					if (halt == txr_thread_status.jump) {
						th[@txr_thread.status] = txr_thread_status.running;
						ds_stack_push(stack, v);
					}
					continue;
				}
				ds_stack_push(stack, v);
				break;
			case txr_action.ret: pos = len; break;
			case txr_action.discard:
				if (ds_stack_empty(stack)) show_error("Discard on an empty stack! Suspicious.", 0);
				ds_stack_pop(stack);
				break;
			case txr_action.jump: pos = q[2]; break;
			case txr_action.jump_unless:
				if (ds_stack_pop(stack)) {
					// OK!
				} else pos = q[2];
				break;
			case txr_action.jump_if:
				if (ds_stack_pop(stack)) pos = q[2];
				break;
			case txr_action.band:
				if (ds_stack_top(stack)) {
					ds_stack_pop(stack);
				} else pos = q[2];
				break;
			case txr_action.bor:
				if (ds_stack_top(stack)) {
					pos = q[2];
				} else ds_stack_pop(stack);
				break;
			case txr_action.jump_push:
				ds_stack_push(th[txr_thread.jumpstack], pos);
				pos = q[2];
				break;
			case txr_action.jump_pop:
				pos = ds_stack_pop(th[txr_thread.jumpstack]);
				break;
			case txr_action._select:
				var v = ds_stack_pop(stack);
				var posx = q[2];
				if (txr_is_number(v) && v >= 0 && v < array_length(posx)) {
					pos = posx[v];
				} else pos = q[3];
				break;
			case txr_action.dup:
				ds_stack_push(stack, ds_stack_top(stack));
				break;
			case txr_action._switch:
				var v = ds_stack_pop(stack);
				if (v == ds_stack_top(stack)) {
					ds_stack_pop(stack);
					pos = q[2];
				}
				break;
			case txr_action.get_array:
				var i = ds_stack_pop(stack);
				var a = ds_stack_pop(stack);
				if (is_array(a)) {
					if (txr_is_number(i)) {
						if (i >= 0 && i < array_length(a)) {
							ds_stack_push(stack, a[i]);
						} else halt = txr_sfmt("Index `%` is out of range (0...% excl.) for get", i, array_length(a));
					} else halt = txr_sfmt("`%` (%) is not an index for get", i, typeof(i));
				} else halt = txr_sfmt("`%` (%) is not an array for get", a, typeof(a));
				break;
			case txr_action.set_array:
				var i = ds_stack_pop(stack);
				var a = ds_stack_pop(stack);
				var v = ds_stack_pop(stack);
				if (is_array(a)) {
					if (txr_is_number(i)) {
						if (i >= 0 && i < 32000) {
							a[@i] = v;
						} else halt = txr_sfmt("Invalid index `%` for set", i);
					} else halt = txr_sfmt("`%` (%) is not an index for set", i, typeof(i));
				} else halt = txr_sfmt("`%` (%) is not an array for set", a, typeof(a));
				break;
			case txr_action.array_literal:
				var i = q[2];
				var a = array_create(i);
				while (--i >= 0) a[i] = ds_stack_pop(stack);
				ds_stack_push(stack, a);
				break;
			default:
				halt = txr_sfmt("Can't run action ID %", q[0]);
				continue;
		}
	}
	if (halt == undefined) {
		th[@txr_thread.status] = txr_thread_status.finished;
		if (ds_stack_empty(stack)) {
			th[@txr_thread.result] = 0;
		} else th[@txr_thread.result] = ds_stack_pop(stack);
	} else if (is_string(halt)) {
		th[@txr_thread.status] = txr_thread_status.error;
		th[@txr_thread.result] = halt + " at " + txr_print_pos(q[1]);
	}
	th[@txr_thread.pos] = pos;
	txr_thread_current = _previous;
	return th[txr_thread.status];
}
