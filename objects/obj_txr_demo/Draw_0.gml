draw_set_font(fnt_test);
draw_set_color(c_white);
var s, v;
if (program != undefined) {
	v = txr_exec(program);
	if (txr_error != "") {
	    s = "<error> " + txr_error;
	} else {
		s = scr_txr_demo_af(v);
	}
} else s = error;
draw_text_ext(4, 4, "Type an expression and press Enter."
	+ "\nInput: " + keyboard_string
	+ "\nOutput: " + s,
	-1, room_width - 8);
if (keyboard_check_pressed(vk_enter)) {
	program = txr_compile(keyboard_string);
	if (program == undefined) {
		error = "<error> " + txr_error;
	}
}