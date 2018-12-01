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
    default:
        txr_build_pos -= 1;
        if (txr_build_expr(0)) return true;
        switch (txr_build_node[0]) {
            case txr_node.call:
                // select expressions are allowed to be statements,
                // and are compiled to `discard <value>` so that we don't clog the stack
                txr_build_node = [txr_node.discard, txr_build_node[1], txr_build_node];
                break;
            default: return txr_throw_at("Expected a statement", txr_build_node);
        }
}