/// @param actions
/// @param ?arguments:array|ds_map
var arr = argument[0];
var argd = argument_count > 1 ? argument[1] : undefined;
var len = array_length_1d(arr);
var pos = 0;
var stack = ds_stack_create();
var locals = ds_map_create();
if (argd != undefined) {
    if (is_array(argd)) { // an array of arguments
        var i = array_length_1d(argd);
        locals[?"argument_count"] = i;
        locals[?"argument"] = argd;
        while (--i >= 0) locals[?"argument" + string(i)] = argd[i];
    } else { // a ds_map with initial local scope
        ds_map_copy(locals, argd);
    }
}
while (pos < len) {
    var q = arr[pos++];
    switch (q[0]) {
        case txr_action.number: ds_stack_push(stack, q[2]); break;
        case txr_action._string: ds_stack_push(stack, q[2]); break;
        case txr_action.unop:
            var v = ds_stack_pop(stack);
            if (q[2] == txr_unop.invert) {
                ds_stack_push(stack, v ? false : true);
            } else if (is_string(v)) {
                return txr_exec_exit("Can't apply unary - to string", q, stack, locals);
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
                } else return txr_exec_exit("Can't apply operator " + string(q[2])
                    + " to " + typeof(a) + " and " + typeof(b), q, stack, locals);
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
                default: return txr_exec_exit("Can't apply operator " + string(q[2]), q, stack, locals);
            } else return txr_exec_exit("Can't apply operator " + string(q[2])
                + " to " + typeof(a) + " and " + typeof(b), q, stack, locals);
            ds_stack_push(stack, a);
            break;
        case txr_action.ident:
            var v = variable_instance_get(id, q[2]);
            ds_stack_push(stack, v);
            break;
        case txr_action.set_ident:
            variable_instance_set(id, q[2], ds_stack_pop(stack));
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
            switch (q[3]) {
                case 0: v = script_execute(q[2]); break;
                case 1: v = script_execute(q[2], args[|0]); break;
                case 2: v = script_execute(q[2], args[|0], args[|1]); break;
                case 3: v = script_execute(q[2], args[|0], args[|1], args[|2]); break;
                // and so on
                default: return txr_exec_exit("Too many arguments (" + string(q[3]) + ")", q, stack, locals);
            }
            if (txr_function_error == undefined) {
                ds_stack_push(stack, v);
            } else return txr_exec_exit(txr_function_error, q, stack, locals);
            break;
        case txr_action.ret: pos = len; break;
        case txr_action.discard: ds_stack_pop(stack); break;
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
        default: return txr_exec_exit("Can't run action " + string(q[0]), q, stack, locals);
    }
}
var r;
if (ds_stack_empty(stack)) {
    r = 0; // if nothing is returned, assume 0 to be returned
} else r = ds_stack_pop(stack);
ds_stack_destroy(stack);
txr_error = "";
return r;