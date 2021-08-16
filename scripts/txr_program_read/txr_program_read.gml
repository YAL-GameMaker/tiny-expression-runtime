/// @param buffer
function txr_program_read(argument0) {
	var b/*:Buffer*/ = argument0;
	var n = buffer_read(b, buffer_u32);
	var w = array_create(n);
	for (var i = 0; i < n; i++) {
		w[i] = txr_action_read(b);
	}
	return w;
}
