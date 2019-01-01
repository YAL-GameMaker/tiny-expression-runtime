/// dlg(prompt, ...options)
var th = txr_thread_yield();
if (th != undefined)
with (instance_create_depth(0, 0, 0, obj_txr_demo_dialog)) {
    thread = th;
    prompt = argument[0];
    var n = argument_count - 1;
    options = array_create(n);
    option_heights = array_create(n);
    for (var i = 0; i < n; i++) options[i] = argument[i + 1];
}