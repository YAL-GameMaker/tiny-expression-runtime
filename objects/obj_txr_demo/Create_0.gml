txr_init();
txr_function_add("abs", scr_txr_demo_abs, 1);
txr_function_add("lerp", scr_txr_demo_lerp, 3);
txr_function_add("draw_text", scr_txr_demo_draw_text, 3);
program = undefined;
text = "";
error = "";
keyboard_string = "";