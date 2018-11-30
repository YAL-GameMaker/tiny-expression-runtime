var tk = txr_build_list[|txr_build_pos++];
switch (tk[0]) {
    case txr_token.ret: // return <expr>
        if (txr_build_expr(0)) return true;
        txr_build_node = [txr_node.ret, tk[1], txr_build_node];
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