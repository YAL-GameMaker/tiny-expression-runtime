txr_init();
txr_function_add("abs", scr_txr_demo_abs, 1);
txr_function_add("lerp", scr_txr_demo_lerp, 3);
txr_function_add("draw_text", scr_txr_demo_draw_text, 3);
program = undefined;
text = "";
error = "";
// other scripts or anything
global.extra_functions = ds_map_create();
global.extra_functions[?"hi"] = txr_compile(@'
if (argument_count > 0) {
    return "hi, " + argument0 + "!";
} else return "hi!";
');
txr_function_default = scr_txr_demo_default_func;

keyboard_string = "";