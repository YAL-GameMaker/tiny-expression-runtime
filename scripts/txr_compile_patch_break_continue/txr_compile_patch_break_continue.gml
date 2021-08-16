/// @param start_pos
/// @param end_pos
/// @param break_pos
/// @param continue_pos
function txr_compile_patch_break_continue(argument0, argument1, argument2, argument3) {
	var start = argument0;
	var till = argument1;
	var _break = argument2;
	var _continue = argument3;
	var out = txr_compile_list;
	for (var i = start; i < till; i++) {
		var act = out[|i];
		if (act[0] == txr_action.jump) switch (act[2]) {
			case -10: if (_break >= 0) act[@2] = _break; break;
			case -11: if (_continue >= 0) act[@2] = _continue; break;
		}
	}
}
