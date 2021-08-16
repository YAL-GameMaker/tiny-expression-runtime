/// @param {string} name
/// @param {string|number|undefined} value
/// Registers a constant
function txr_constant_add(_name, _value) {
	if (is_string(_value) || is_numeric(_value) || is_undefined(_value)) {
		global.txr_constant_map[?_name] = _value;
	} else show_error("Expected a string or a number for constant, got " + typeof(_value), true);
}
