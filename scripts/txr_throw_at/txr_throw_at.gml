/// @param error_text
/// @param token
function txr_throw_at(argument0, argument1) {
	var tk = argument1;
	if (tk[0] == txr_token.eof) {
		return txr_throw(argument0, "<EOF>");
	} else return txr_throw(argument0, txr_print_pos(tk[1]));
}
