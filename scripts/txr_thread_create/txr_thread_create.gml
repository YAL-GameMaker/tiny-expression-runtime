/// @param actions
/// @param ?arguments:array|ds_map
function txr_thread_create() {
	var arr = argument[0];
	var argd = argument_count > 1 ? argument[1] : undefined;
	var th/*:txr_thread*/ = array_create(txr_thread.sizeof);
	th[@txr_thread.actions] = arr;
	th[@txr_thread.pos] = 0;
	th[@txr_thread.stack] = ds_stack_create();
	th[@txr_thread.jumpstack] = ds_stack_create();
	var locals = ds_map_create();
	if (argd != undefined) {
		if (is_array(argd)) { // an array of arguments
			var i = array_length(argd);
			locals[?"argument_count"] = i;
			locals[?"argument"] = argd;
			while (--i >= 0) locals[?"argument" + string(i)] = argd[i];
		} else { // a ds_map with initial local scope
			ds_map_copy(locals, argd);
		}
	}
	th[@txr_thread.locals] = locals;
	th[@txr_thread.status] = txr_thread_status.running;
	return th;
	enum txr_thread {
		actions,
		pos,
		//
		stack,
		jumpstack,
		locals,
		//
		result, // status-specific, e.g. returned value or error text
		status,
		//
		sizeof,
	}
	enum txr_thread_status {
		none, // not ran yet
		running, // in process
		finished, // finished executing in a normal way
		error, // hit an error
		yield, // requested to yield
		jump, // requested to transit to a different position
	}
}
