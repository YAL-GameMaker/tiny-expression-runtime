/// @param action
/// @param buffer
function txr_action_write(argument0, argument1) {
	var a = argument0, b/*:Buffer*/ = argument1;
	buffer_write(b, buffer_u8, a[0]);
	buffer_write(b, buffer_u32, a[1]);
	switch (a[0]) {
		case txr_action.number: buffer_write(b, buffer_f64, a[2]); break;
		case txr_action.unop: buffer_write(b, buffer_u8, a[2]); break;
		case txr_action.binop: buffer_write(b, buffer_u8, a[2]); break;
		case txr_action.call:
			buffer_write(b, buffer_string, script_get_name(a[2]));
			buffer_write(b, buffer_u32, a[3]);
			break;
		case txr_action.ret:
		case txr_action.discard:
		case txr_action.jump_pop:
		case txr_action.dup:
		case txr_action.get_array:
		case txr_action.set_array:
			break;
		case txr_action.jump:
		case txr_action.jump_unless:
		case txr_action.jump_if:
		case txr_action.jump_push:
		case txr_action.band:
		case txr_action.bor:
		case txr_action._switch:
		case txr_action.array_literal:
			buffer_write(b, buffer_s32, a[2]);
			break;
		case txr_action._string:
		case txr_action.label:
		case txr_action.set_ident:
		case txr_action.ident:
		case txr_action.get_local:
		case txr_action.set_local:
		case txr_action.get_field:
		case txr_action.set_field:
			buffer_write(b, buffer_string, a[2]);
			break;
		case txr_action._select:
			var w = a[2];
			var n = array_length(w);
			buffer_write(b, buffer_u32, n);
			for (var i = 0; i < n; i++) buffer_write(b, buffer_s32, w[i]);
			buffer_write(b, buffer_s32, a[3]);
			break;
		default:
			show_error(txr_sfmt("Please add a writer for action type % to txr_action_write!", a[0]), 1);
	}
}
