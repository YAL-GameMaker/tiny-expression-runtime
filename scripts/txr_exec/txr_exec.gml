/// @param {string|array} code_or_actions
/// @param {array|struct|ds_map} ?args
function txr_exec(_code_or_actions, _args = undefined) {
	if (is_string(_code_or_actions)) {
		return txr_exec_string(_code_or_actions /*#as string*/, _args);
	} else {
		return txr_exec_actions(_code_or_actions /*#as array*/, _args);
	}
}