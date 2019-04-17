var q = argument0;
var out/*:List*/ = txr_compile_list;
switch (q[0]) {
    case txr_node.ident:
        var s = q[2];
        if (ds_map_exists(global.txr_constant_map, s)) {
            return txr_throw_at("Constants are not settable", q);
        } else if (ds_map_exists(txr_build_locals, s)) {
            ds_list_add(out, [txr_action.set_local, q[1], s]);
        } else {
            ds_list_add(out, [txr_action.set_ident, q[1], s]);
        }
        return false;
    default: return txr_throw_at("Expression is not settable", q);
}