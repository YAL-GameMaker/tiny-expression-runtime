/// @param {string} code
/// @param {array|struct|ds_map} ?args
function txr_exec_string(_code, _args = undefined) {
	var _actions = txr_compile(_code);
	if (_actions == undefined) return undefined;
	return txr_exec_actions(_actions, _args);
}