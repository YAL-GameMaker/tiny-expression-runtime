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
    case txr_token._while: // while <condition-expr> <loop-expr>
        if (txr_build_expr(0)) return true;
        var _cond = txr_build_node;
        if (txr_build_loop_body()) return true;
        txr_build_node = [txr_node._while, tk[1], _cond, txr_build_node];
        break;
    case txr_token._do: // do <loop-expr> while <condition-expr>
        if (txr_build_loop_body()) return true;
        var _loop = txr_build_node;
        // expect a `while`:
        tkn = txr_build_list[|txr_build_pos];
        if (tkn[0] != txr_token._while) return txr_throw_at("Expected a `while` after do", tkn);
        txr_build_pos += 1;
        // read condition:
        if (txr_build_expr(0)) return true;
        txr_build_node = [txr_node.do_while, tk[1], _loop, txr_build_node];
        break;
    case txr_token._for: // for (<init>; <cond-expr>; <post>) <loop>
        // see if there's a `(`:
        tkn = txr_build_list[|txr_build_pos];
        var _par = tkn[0] == txr_token.par_open;
        if (_par) txr_build_pos += 1;
        // read init:
        if (txr_build_stat()) return true;
        var _init = txr_build_node;
        // read condition:
        if (txr_build_expr(0)) return true;
        var _cond = txr_build_node;
        tkn = txr_build_list[|txr_build_pos];
        if (tkn[0] == txr_token.semico) txr_build_pos += 1;
        // read post-statement:
        if (txr_build_stat()) return true;
        var _post = txr_build_node;
        // see if there's a matching `)`?:
        if (_par) {
            tkn = txr_build_list[|txr_build_pos];
            if (tkn[0] != txr_token.par_close) return txr_throw_at("Expected a `)`", tkn);
            txr_build_pos += 1;
        }
        // finally read the loop body:
        if (txr_build_loop_body()) return true;
        txr_build_node = [txr_node._for, tk[1], _init, _cond, _post, txr_build_node];
        break;
    case txr_token._break:
        if (txr_build_can_break) {
            txr_build_node = [txr_node._break, tk[1]];
        } else return txr_throw_at("Can't `break` here", tk);
        break;
    case txr_token._continue:
        if (txr_build_can_continue) {
            txr_build_node = [txr_node._continue, tk[1]];
        } else return txr_throw_at("Can't `continue` here", tk);
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
// allow a semicolon after statements:
tk = txr_build_list[|txr_build_pos];
if (tk[0] == txr_token.semico) txr_build_pos += 1;