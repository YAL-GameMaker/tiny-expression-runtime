/// @param buffer
function txr_value_read(argument0) {
	var b/*:Buffer*/ = argument0;
	switch (buffer_read(b, buffer_u8)) {
		case 1: return buffer_read(b, buffer_f64);
		case 2: return buffer_read(b, buffer_u64);
		case 3: return buffer_read(b, buffer_s32);
		case 4: return buffer_read(b, buffer_bool);
		case 5: return buffer_read(b, buffer_string);
		case 6:
			var n = buffer_read(b, buffer_u32);
			var r = array_create(n);
			for (var i = 0; i < n; i++) {
				r[i] = txr_value_read(b);
			}
			return r;
		default: return undefined;
	}
}
