/// @param name
/// @param value
/// Registers a constant
var v = argument1;
if (is_string(v) || is_real(v) || is_bool(v) || is_int32(v) || is_int64(v)) {
	global.txr_constant_map[?argument0] = argument1;
} else show_error("Expected a string or a number for constant, got " + typeof(v), true);