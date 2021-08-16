/// @param val
/// @param want
function scr_txr_demo_assert() {
	var _val = argument[0], _want = argument[1];
	var _label = argument_count > 2 ? argument[2] : "?";
	var _error = false;
	if (is_array(_want)) {
		if (is_array(_val)) {
			var n = array_length(_want);
			if (n != array_length(_val)) {
				_error = true;
			} else for (var i = 0; i < n; i++) {
				if (!scr_txr_demo_assert(_val[i], _want[i])) {
					_error = true;
					break;
				}
			}
		} else {
			_error = true;
			return false;
		}
	} else if (_val != _want) {
		_error = true;
	}
	if (_error) {
		txr_function_error = txr_sfmt("Expected `%` (%), got `%` (%) for %",
			_want, typeof(_want), _val, typeof(_val), _label,
		);
		return false;
	}
	return true;
}
