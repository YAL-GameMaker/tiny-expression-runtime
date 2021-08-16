/// @param buffer
/// @return action
function txr_action_read(argument0) {
	var b/*:Buffer*/ = argument0;
	var t = buffer_read(b, buffer_u8);
	var p = buffer_read(b, buffer_u32);
	switch (t) {
		case txr_action.number: return [t, p, buffer_read(b, buffer_f64)];
		case txr_action.unop:
		case txr_action.binop:
			return [t, p, buffer_read(b, buffer_u8)];
		case txr_action.call:
			var q = asset_get_index(buffer_read(b, buffer_string));
			return [t, p, q, buffer_read(b, buffer_u32)];
		case txr_action.ret:
		case txr_action.discard:
		case txr_action.jump_pop:
		case txr_action.dup:
		case txr_action.get_array:
		case txr_action.set_array:
			return [t, p];
		case txr_action.jump:
		case txr_action.jump_unless:
		case txr_action.jump_if:
		case txr_action.jump_push:
		case txr_action.band:
		case txr_action.bor:
		case txr_action._switch:
		case txr_action.array_literal:
			return [t, p, buffer_read(b, buffer_s32)];
			break;
		case txr_action._string:
		case txr_action.label:
		case txr_action.set_ident:
		case txr_action.ident:
		case txr_action.get_local:
		case txr_action.set_local:
		case txr_action.get_field:
		case txr_action.set_field:
			return [t, p, buffer_read(b, buffer_string)];
			break;
		case txr_action._select:
			var n = buffer_read(b, buffer_u32);
			var w = array_create(n);
			for (var i = 0; i < n; i++) w[i] = buffer_read(b, buffer_s32);
			return [t, p, w, buffer_read(b, buffer_s32)];
			//
			//
		default:
			show_error(txr_sfmt("Please add a read for action type % to txr_action_read!", t), 1);
	}
}
