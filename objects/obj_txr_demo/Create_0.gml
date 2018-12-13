txr_init();
txr_function_add("abs", scr_txr_demo_abs, 1);
txr_function_add("lerp", scr_txr_demo_lerp, 3);
txr_function_add("draw_text", scr_txr_demo_draw_text, 3);
txr_function_add("trace", scr_txr_demo_trace, -1);
txr_function_add("wait", scr_txr_demo_wait, 1);
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

//
var pg = txr_compile(@'
    for (var i = 1; i <= 15; i = i + 1) {
        wait(1);
        trace(i + "!");
    }
');
var th = txr_thread_create(pg);
if (txr_thread_resume(th) == txr_thread_status.error) {
    show_debug_message(th[txr_thread.result]);
}

keyboard_string = "";