/// @desc Converts a number to string with automatic precision.
/// @arg number
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