/// @param {string} name
/// @param {script|function} script
/// @param {int} arg_count
/// Registers a script for use as a function in TXR programs
function txr_function_add(_name, _script, _argc) {
	global.txr_function_map[?_name] = [_script, _argc];
}
