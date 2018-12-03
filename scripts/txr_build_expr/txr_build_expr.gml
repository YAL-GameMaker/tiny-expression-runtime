/// @param flags
var flags = argument0;
var tk = txr_build_list[|txr_build_pos++];
switch (tk[0]) {
    case txr_token.number: txr_build_node = [txr_node.number, tk[1], tk[2]]; break;
    case txr_token._string: txr_build_node = [txr_node._string, tk[1], tk[2]]; break;
    case txr_token.ident:
        var tkn = txr_build_list[|txr_build_pos];
        if (tkn[0] == txr_token.par_open) { // `ident(`
            txr_build_pos += 1;
            // read the arguments and the closing `)`:
            var args = [], argc = 0, closed = false;
            while (txr_build_pos < txr_build_len) {
                // hit a closing `)` yet?
                tkn = txr_build_list[|txr_build_pos];
                if (tkn[0] == txr_token.par_close) {
                    txr_build_pos += 1;
                    closed = true;
                    break;
                }
                // read the argument:
                if (txr_build_expr(0)) return true;
                args[argc++] = txr_build_node;
                // skip a `,`:
                tkn = txr_build_list[|txr_build_pos];
                if (tkn[0] == txr_token.comma) {
                    txr_build_pos += 1;
                } else if (tkn[0] != txr_token.par_close) {
                    return txr_throw_at("Expected a `,` or `)`", tkn);
                }
            }
            if (!closed) return txr_throw_at("Unclosed `()` after", tk);
            // find the function, verify argument count, and finally pack up:
            var fn = global.txr_function_map[?tk[2]];
            if (fn == undefined) return txr_throw_at("Unknown function `" + tk[2] + "`", tk);
            if (fn[1] >= 0 && argc != fn[1]) return txr_throw_at("`" + tk[2] + "` takes "
                + string(fn[1]) + " argument(s), got " + string(argc), tk);
            txr_build_node = [txr_node.call, tk[1], fn[0], args];
        } else txr_build_node = [txr_node.ident, tk[1], tk[2]];
        break;
    case txr_token.par_open: // (value)
        if (txr_build_expr(0)) return true;
        tk = txr_build_list[|txr_build_pos++];
        if (tk[0] != txr_token.par_close) return txr_throw_at("Expected a `)`", tk);
        break;
    case txr_token.op: // -value, +value
        switch (tk[2]) {
            case txr_op.add:
                if (txr_build_expr(txr_build_flag.no_ops)) return true;
                break;
            case txr_op.sub:
                if (txr_build_expr(txr_build_flag.no_ops)) return true;
                txr_build_node = [txr_node.unop, tk[1], txr_unop.negate, txr_build_node];
                break;
            default: return txr_throw_at("Expected an expression", tk);
        }
        break;
    default: return txr_throw_at("Expected an expression", tk);
}
if ((flags & txr_build_flag.no_ops) == 0) {
    tk = txr_build_list[|txr_build_pos];
    if (tk[0] == txr_token.op) {
        txr_build_pos += 1;
        if (txr_build_ops(tk)) return true;
    }
}
return false;