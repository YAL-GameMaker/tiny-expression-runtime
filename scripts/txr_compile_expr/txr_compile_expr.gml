/// @param node
var q = argument0;
var out/*:List*/ = txr_compile_list;
switch (q[0]) {
    case txr_node.number: ds_list_add(out, [txr_action.number, q[1], q[2]]); break;
    case txr_node._string: ds_list_add(out, [txr_action._string, q[1], q[2]]); break;
    case txr_node.ident:
        if (ds_map_exists(txr_build_locals, q[2])) {
            ds_list_add(out, [txr_action.get_local, q[1], q[2]]);
        } else ds_list_add(out, [txr_action.ident, q[1], q[2]]);
        break;
    case txr_node._argument: ds_list_add(out, [txr_action.get_local, q[1], q[3]]); break;
    case txr_node._argument_count: ds_list_add(out, [txr_action.get_local, q[1], "argument_count"]); break;
    case txr_node.unop:
        if (txr_compile_expr(q[3])) return true;
        ds_list_add(out, [txr_action.unop, q[1], q[2]]);
        break;
    case txr_node.binop:
        switch (q[2]) {
            case txr_op.band:
                if (txr_compile_expr(q[3])) return true;
                var jmp = [txr_action.band, q[1], 0];
                ds_list_add(out, jmp);
                if (txr_compile_expr(q[4])) return true;
                jmp[@2] = ds_list_size(out);
                break;
            case txr_op.bor:
                if (txr_compile_expr(q[3])) return true;
                var jmp = [txr_action.bor, q[1], 0];
                ds_list_add(out, jmp);
                if (txr_compile_expr(q[4])) return true;
                jmp[@2] = ds_list_size(out);
                break;
            default:
                if (txr_compile_expr(q[3])) return true;
                if (txr_compile_expr(q[4])) return true;
                ds_list_add(out, [txr_action.binop, q[1], q[2]]);
        }
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
    case txr_node._select:
        // select [l1, l2], l3
        // l1: option 1; jump l4
        // l2: option 2; jump l4
        // l3: default
        // l4: ...
        if (txr_compile_expr(q[2])) return true;
        // selector node:
        var opts = q[3];
        var optc = array_length_1d(opts);
        var sel_jmps = array_create(optc);
        var opt_jmps = array_create(optc);
        var sel = [txr_action._select, q[1], sel_jmps, 0];
        ds_list_add(out, sel);
        // options:
        for (var i = 0; i < optc; i++) {
            sel_jmps[@i] = ds_list_size(out);
            if (txr_compile_expr(opts[i])) return true;
            var jmp = [txr_action.jump, q[1], 0];
            opt_jmps[@i] = jmp;
            ds_list_add(out, jmp);
        }
        // default;
        sel[@3] = ds_list_size(out);
        if (q[4] != undefined) {
            if (txr_compile_expr(q[4])) return true;
        }
        // point end-of-option jumps to the end of select:
        for (var i = 0; i < optc; i++) {
            var jmp = opt_jmps[i];
            jmp[@2] = ds_list_size(out);
        }
        break;
    case txr_node.set:
        if (txr_compile_expr(q[3])) return true;
        var _expr = q[2];
        switch (_expr[0]) {
            case txr_node.ident:
                if (ds_map_exists(txr_build_locals, _expr[2])) {
                    ds_list_add(out, [txr_action.set_local, q[1], _expr[2]]);
                } else ds_list_add(out, [txr_action.set_ident, q[1], _expr[2]]);
                break;
            default: return txr_throw_at("Expression is not settable", _expr);
        }
        break;
    case txr_node._while:
        // l1: {cont} <condition> jump_unless l2
        var pos_cont = ds_list_size(out);
        if (txr_compile_expr(q[2])) return true;
        var jmp = [txr_action.jump_unless, q[1], 0];
        ds_list_add(out, jmp);
        // <loop> jump l1
        var pos_start = ds_list_size(out);
        if (txr_compile_expr(q[3])) return true;
        ds_list_add(out, [txr_action.jump, q[1], pos_cont]);
        // l2: {break}
        var pos_break = ds_list_size(out);
        jmp[@2] = pos_break;
        txr_compile_patch_break_continue(pos_start, pos_break, pos_break, pos_cont);
        break;
    case txr_node.do_while:
        // l1: <loop>
        var pos_start = ds_list_size(out);
        if (txr_compile_expr(q[2])) return true;
        // l2: {cont} <condition> jump_if l1
        var pos_cont = ds_list_size(out);
        if (txr_compile_expr(q[3])) return true;
        ds_list_add(out, [txr_action.jump_if, q[1], pos_start]);
        // l3: {break}
        var pos_break = ds_list_size(out);
        txr_compile_patch_break_continue(pos_start, pos_break, pos_break, pos_cont);
        break;
    case txr_node._for:
        if (txr_compile_expr(q[2])) return true;
        // l1: <condition> jump_unless l3
        var pos_loop = ds_list_size(out);
        if (txr_compile_expr(q[3])) return true;
        var jmp = [txr_action.jump_unless, q[1], 0];
        ds_list_add(out, jmp);
        // <loop>
        var pos_start = ds_list_size(out);
        if (txr_compile_expr(q[5])) return true;
        // l2: {cont} <post> jump l1
        var pos_cont = ds_list_size(out);
        if (txr_compile_expr(q[4])) return true;
        ds_list_add(out, [txr_action.jump, q[1], pos_loop]);
        // l3: {break}
        var pos_break = ds_list_size(out);
        jmp[@2] = pos_break;
        txr_compile_patch_break_continue(pos_start, pos_break, pos_break, pos_cont);
        break;
    case txr_node._break: ds_list_add(out, [txr_action.jump, q[1], -10]); break;
    case txr_node._continue: ds_list_add(out, [txr_action.jump, q[1], -11]); break;
    case txr_node.label:
        var lbs = txr_compile_labels[?q[2]];
        if (lbs == undefined) {
            lbs = [ds_list_size(out)];
            txr_compile_labels[?q[2]] = lbs;
        } else lbs[@0] = ds_list_size(out);
        txr_compile_expr(q[3]);
        break;
    case txr_node.jump:
    case txr_node.jump_push:
        var lbs = txr_compile_labels[?q[2]];
        if (lbs == undefined) {
            lbs = [undefined];
            txr_compile_labels[?q[2]] = lbs;
        }
        var i = (q[0] == txr_node.jump ? txr_action.jump : txr_action.jump_push);
        var jmp = [i, q[1], undefined];
        ds_list_add(out, jmp);
        lbs[@array_length_1d(lbs)] = jmp;
        break;
    case txr_node.jump_pop:
        ds_list_add(out, [txr_action.jump_pop, q[1]]);
        break;
    default: return txr_throw_at("Cannot compile node type " + string(q[0]), q);
}
return false;