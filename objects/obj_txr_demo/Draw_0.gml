draw_set_font(fnt_test);
draw_set_color(c_white);
mx = mouse_x;
my = mouse_y;
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
if (keyboard_check(vk_control) && os_browser == browser_not_a_browser) {
    if (keyboard_check_pressed(ord("C"))) clipboard_set_text(keyboard_string);
    if (keyboard_check_pressed(ord("V"))) keyboard_string = clipboard_get_text();
}
if (keyboard_check_pressed(vk_enter)) {
    program = txr_compile(keyboard_string);
    if (program == undefined) {
        error = "<error> " + txr_error;
    }
}
//
if (keyboard_check_pressed(vk_f5)) {
	var b = buffer_create(64, buffer_grow, 1);
	txr_thread_write(global.long_exec_th, b);
	buffer_save_ext(b, "long.th", 0, buffer_tell(b));
	buffer_delete(b);
}
if (keyboard_check_pressed(vk_f6) && file_exists("long.th")) {
	// clean up the existing thread and anything related:
	var th = global.long_exec_th;
	with (obj_txr_demo_wait) if (thread == th) instance_destroy();
	txr_thread_destroy(th);
	//
	var b = buffer_load("long.th");
	buffer_seek(b, buffer_seek_start, 0);
	th = txr_thread_read(b);
	buffer_delete(b);
	global.long_exec_th = th;
	txr_thread_resume(th);
}