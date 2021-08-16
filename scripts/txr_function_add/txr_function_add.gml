/// @param name
/// @param script
/// @param arg_count
/// Registers a script for use as a function in TXR programs
function txr_function_add(argument0, argument1, argument2) {
	global.txr_function_map[?argument0] = [argument1, argument2];
}
