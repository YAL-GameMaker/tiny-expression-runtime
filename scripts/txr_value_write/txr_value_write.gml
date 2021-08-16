/// @param value
/// @param buffer
function txr_value_write(argument0, argument1) {
	var v = argument0, b/*:Buffer*/ = argument1;
	if (is_real(v)) {
		buffer_write(b, buffer_u8, 1);
		buffer_write(b, buffer_f64, v);
	} else if (is_int64(v)) {
		buffer_write(b, buffer_u8, 2);
		buffer_write(b, buffer_u64, v);
	} else if (is_int32(v)) {
		buffer_write(b, buffer_u8, 3);
		buffer_write(b, buffer_s32, v);
	} else if (is_bool(v)) {
		buffer_write(b, buffer_u8, 4);
		buffer_write(b, buffer_bool, v);
	} else if (is_string(v)) {
		buffer_write(b, buffer_u8, 5);
		buffer_write(b, buffer_string, v);
	} else if (is_array(v)) {
		buffer_write(b, buffer_u8, 6);
		var n = array_length(v);
		buffer_write(b, buffer_u32, n);
		for (var i = 0; i < n; i++) {
			txr_value_write(v[i], b);
		}
	} else {
		buffer_write(b, buffer_u8, 0);
	}
}
