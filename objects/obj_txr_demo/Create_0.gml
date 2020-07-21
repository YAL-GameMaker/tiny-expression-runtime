txr_init();
txr_function_add("abs", scr_txr_demo_abs, 1);
txr_function_add("lerp", scr_txr_demo_lerp, 3);
txr_function_add("draw_text", scr_txr_demo_draw_text, 3);
txr_function_add("trace", scr_txr_demo_trace, -1);
txr_function_add("wait", scr_txr_demo_wait, 1);
txr_function_add("dialog", scr_txr_demo_dlg, -1);
txr_function_add("call_label", scr_txr_demo_call_label, 1);
txr_function_add("get_dummy", scr_txr_demo_get_dummy, 0);
txr_constant_add("noone", noone);
program = undefined;
text = "";
error = "";
// other scripts or anything
global.extra_functions = ds_map_create();
global.extra_functions[?"hi"] = txr_compile(/*gml*/@'
if (argument_count > 0) {
    return "hi, " + argument0 + "!";
} else return "hi!";
');
txr_function_default = scr_txr_demo_default_func;

//
dummy = instance_create_depth(0, 0, 0, obj_txr_demo_wait);
dummy.some = "hi!";
var pg = txr_compile(/*gml*/@'
    trace("start");
    call_label("howdy");
    // try out fields:
    trace(dummy.some);
    dummy.some += "!!";
    trace(dummy.some);
    trace(get_dummy().some);
    // try out prefix/postfix/assignment variants
    var i = 1;
    trace("i++", i++);
    trace("++i", ++i);
    --i; trace("--i;", i);
    i += 3; trace("i+=3;", i);
    // try out switch blocks:
    for (var i = 0; i < 4; i++) switch (i) {
        case 0: trace("0"); break;
        case 1: trace("1 (fall-through)");
        case 2: trace("2"); break;
        default: trace("default");
    }
    //
    label hello: select dialog("Hello! What would you like to do?") {
        option "Count to 5":
            for (var i = 1; i <= 5; i = i + 1) {
                wait(1);
                trace(i + "!");
            }
        option "Count to 15":
            for (var i = 1; i <= 15; i = i + 1) {
                wait(1);
                trace(i + "!");
            }
        option "Nothing": jump yousure
        default: // this one would not happen unless you return an out-of-range value
    }
    label another: select (dialog("Another round?")) {
        option "Sure": jump hello
        option "No": trace("See you later then!"); return 1
    }
    label yousure: select dialog("You sure?") {
        option "Yes":
            select dialog("Really sure?") {
                option "Absolutely": trace("Well then,"); return 0
                option "Maybe not": jump hello
            }
        option "No": jump hello
    }
    return 0
    label howdy: // called by-name via call_label above
        trace("Howdy");
        back
');
if (pg == undefined) {
    show_debug_message(txr_error);
} else {
    //show_debug_message(txr_program_print(pg));
}
var th/*:txr_thread*/ = txr_thread_create(pg);
if (txr_thread_resume(th) == txr_thread_status.error) {
    show_debug_message(th[txr_thread.result]);
}
global.long_exec_th = th;

keyboard_string = "";