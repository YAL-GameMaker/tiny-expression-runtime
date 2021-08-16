function txr_program_print(argument0) {
	gml_pragma("global", @'
		global.txr_program_print_buf = buffer_create(1024, buffer_grow, 1);
	');
	var pg = argument0;
	var n = array_length(pg);
	var nn = string_length(string(n));
	var b/*:Buffer*/ = global.txr_program_print_buf;
	buffer_seek(b, 0, 0);
	for (var i = 0; i < n; i++) {
		var ist = string(i);
		repeat (nn - string_length(ist)) buffer_write(b, buffer_u8, ord(" "));
		buffer_write(b, buffer_text, ist);
		buffer_write(b, buffer_u8, ord(" "));
		buffer_write(b, buffer_text, txr_action_print(pg[i]));
		buffer_write(b, buffer_u8, 13);
		buffer_write(b, buffer_u8, 10);
	}
	buffer_write(b, buffer_u8, 0);
	buffer_seek(b, 0, 0);
	return buffer_read(b, buffer_string);
}
