// equivalent to running `goto <name>` in thread
var th/*:txr_thread*/ = argument0, label = argument1;
var arr = th[txr_thread.actions];
if (arr == undefined) exit;
var pos = -1;
repeat (array_length_1d(arr)) {
    var act = arr[++pos];
    if (act[0] == txr_action.label && act[2] == label) {
        th[@txr_thread.pos] = pos;
        if (th[txr_thread.status] == txr_thread_status.running) {
            th[@txr_thread.status] = txr_thread_status.jump;
        }
        return true;
    }
}
return false;