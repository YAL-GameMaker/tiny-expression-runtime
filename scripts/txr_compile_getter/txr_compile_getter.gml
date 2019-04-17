var q = argument0;
var out/*:List*/ = txr_compile_list;
switch (q[0]) {
    case txr_node.ident:
        var s = q[2];
        if (ds_map_exists(global.txr_constant_map, s)) {
            var val = global.txr_constant_map[?s];
            if (is_string(val)) {
                ds_list_add(out, [txr_action._string, q[1], val]);
            } else {
                ds_list_add(out, [txr_action.number, q[1], val]);
            }
        } else if (ds_map_exists(txr_build_locals, s)) {
            ds_list_add(out, [txr_action.get_local, q[1], s]);
        } else {
            ds_list_add(out, [txr_action.ident, q[1], s]);
        }
        return false;
    default: return txr_throw_at("Expression is not gettable", q);
}