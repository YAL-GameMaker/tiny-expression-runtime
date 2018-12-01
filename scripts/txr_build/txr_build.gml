txr_build_list = txr_parse_tokens;
txr_build_pos = 0;
txr_build_len = ds_list_size(txr_build_list) - 1; // (the last item is EOF)
var nodes = [];
var found = 0;
while (txr_build_pos < txr_build_len) {
    if (txr_build_stat()) return true;
    nodes[found++] = txr_build_node;
}
txr_build_node = [txr_node.block, 0, nodes];
return false;