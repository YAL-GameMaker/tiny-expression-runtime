var tk = txr_build_list[|txr_build_pos++], tkn;
switch (tk[0]) {
    case txr_token.ret: // return <expr>
        if (txr_build_expr(0)) return true;
        txr_build_node = [txr_node.ret, tk[1], txr_build_node];
        break;
    case txr_token._if: // if <condition-expr> <then-statement> [else <else-statement>]
        if (txr_build_expr(0)) return true;
        var _cond = txr_build_node;
        if (txr_build_stat()) return true;
        var _then = txr_build_node;
        tkn = txr_build_list[|txr_build_pos];
        if (tkn[0] == txr_token._else) { // else <else-statement>
            txr_build_pos += 1;
            if (txr_build_stat()) return true;
            txr_build_node = [txr_node.if_then_else, tk[1], _cond, _then, txr_build_node];
        } else txr_build_node = [txr_node.if_then, tk[1], _cond, _then];
        break;
    case txr_token.cub_open: // { ... statements }
        var nodes = [], found = 0, closed = false;
        while (txr_build_pos < txr_build_len) {
            tkn = txr_build_list[|txr_build_pos];
            if (tkn[0] == txr_token.cub_close) {
                txr_build_pos += 1;
                closed = true;
                break;
            }
            if (txr_build_stat()) return true;
            nodes[found++] = txr_build_node;
        }
        if (!closed) return txr_throw_at("Unclosed {} starting", tk);
        txr_build_node = [txr_node.block, tk[1], nodes];
        break;
    default:
        txr_build_pos -= 1;
        if (txr_build_expr(txr_build_flag.no_ops)) return true;
        var _expr = txr_build_node;
        switch (_expr[0]) {
            case txr_node.call:
                // select expressions are allowed to be statements,
                // and are compiled to `discard <value>` so that we don't clog the stack
                txr_build_node = [txr_node.discard, _expr[1], txr_build_node];
                break;
            default:
                tkn = txr_build_list[|txr_build_pos];
                if (tkn[0] == txr_token.set) { // node = value
                    txr_build_pos += 1;
                    if (txr_build_expr(0)) return true;
                    txr_build_node = [txr_node.set, tkn[1], _expr, txr_build_node];
                } else return txr_throw_at("Expected a statement", txr_build_node);
        }
}