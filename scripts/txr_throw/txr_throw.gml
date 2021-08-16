/// @desc txr_throw(error_text, position)
/// @param error_text
/// @param position
function txr_throw(argument0, argument1) {
	txr_error = argument0 + " at " + string(argument1);
	return true;
}
