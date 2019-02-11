var q = argument0;
var out/*:List*/ = txr_compile_list;
switch (q[0]) {
    case txr_node.ident:
        if (ds_map_exists(txr_build_locals, q[2])) {
            ds_list_add(out, [txr_action.ident, q[1], q[2]]);
        } else {
            ds_list_add(out, [txr_action.get_local, q[1], q[2]]);
        }
        return false;
    default: return txr_throw_at("Expression is not gettable", q);
}