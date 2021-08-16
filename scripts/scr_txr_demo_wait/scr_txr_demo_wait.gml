function scr_txr_demo_wait(argument0) {
	var th = txr_thread_yield();
	if (th != undefined)
	with (instance_create_depth(0, 0, 0, obj_txr_demo_wait)) {
		thread = th;
		alarm[0] = room_speed * argument0;
	}
}
