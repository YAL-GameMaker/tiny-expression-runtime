/// @param {array} actions
/// @param {array|struct|ds_map<string, any>} ?arguments
/// @returns {txr_thread}
function txr_thread_create(arr, argd) {
	var th/*:txr_thread*/ = array_create(txr_thread.sizeof);
	th[@txr_thread.actions] = arr;
	th[@txr_thread.pos] = 0;
	th[@txr_thread.stack] = ds_stack_create();
	th[@txr_thread.jumpstack] = ds_stack_create();
	th[@txr_thread.locals] = {};
	th[@txr_thread.result] = undefined;
	th[@txr_thread.status] = txr_thread_status.running;
	if (argd != undefined) txr_thread_set_args(th, argd);
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
/// @param {txr_thread} actions
/// @param {array|struct|ds_map<string, any>} arguments
function txr_thread_set_args(th/*:txr_thread*/, argd) {
	if (argd == undefined) return;
	if (is_array(argd)) { // an array of arguments
		var args/*:any[]*/ = argd /*#as array*/;
		var i = array_length(args);
		var locals = th[txr_thread.locals];
		locals[$ "argument_count"] = i;
		locals[$ "argument"] = args;
		while (--i >= 0) locals[$ "argument" + string(i)] = args[i];
	} else if (is_struct(argd)) {
		var keys = variable_struct_get_names(argd /*#as struct*/);
		var i = array_length(keys);
		var locals = th[txr_thread.locals];
		while (--i >= 0) {
			var key = keys[i];
			locals[$ key] = argd[$ key];
		}
	} else if (is_numeric(argd)) {
		var keys = ds_map_keys_to_array(argd /*#as ds_map*/);
		var i = array_length(keys);
		var locals = th[txr_thread.locals];
		while (--i >= 0) {
			var key = keys[i];
			locals[$ key] = argd[$ key];
		}
	}
}