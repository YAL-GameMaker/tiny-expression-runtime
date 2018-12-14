/// @param buffer
/// @return action
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
    	return [t, p];
    case txr_action.jump:
    case txr_action.jump_unless:
    case txr_action.jump_if:
    case txr_action.band:
    case txr_action.bor:
    	return [t, p, buffer_read(b, buffer_s32)];
    	break;
    case txr_action._string:
    case txr_action.set_ident:
    case txr_action.ident:
    case txr_action.get_local:
    case txr_action.set_local:
    	return [t, p, buffer_read(b, buffer_string)];
    	break;
    default:
    	show_error(txr_sfmt("Please add a read for action type % to txr_action_read!", t), 1);
}