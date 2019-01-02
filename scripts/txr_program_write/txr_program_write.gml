/// @param program
/// @param buffer
var w = argument0, b/*:Buffer*/ = argument1;
var n = array_length_1d(w);
buffer_write(b, buffer_u32, n);
for (var i = 0; i < n; i++) {
    txr_action_write(w[i], b);
}
return b;