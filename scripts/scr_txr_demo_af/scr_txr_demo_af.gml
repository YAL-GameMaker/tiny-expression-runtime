/// @desc Converts a number to string with automatic precision.
/// @arg number
function scr_txr_demo_af(argument0) {
	var v = argument0;
	if (!is_real(v)) return string(v); // https://bugs.yoyogames.com/view.php?id=30274
	var s = string_format(argument0, 0, 15);
	var d = string_pos(".", s);
	if (d > 0) {
		for (var i = string_byte_length(s); i > d; i -= 1) {
			if (string_byte_at(s, i) != ord("0")) {
				return string_copy(s, 1, i);
			}
		}
		return string_copy(s, 1, d - 1);
	}
	return s;
}
