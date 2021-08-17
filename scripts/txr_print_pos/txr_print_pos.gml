/// @param {int} pos
/// @returns {string}
/// TXR stores positions as row*32000+col. This function decodes that to readable format.
function txr_print_pos(p) {
	var c = p % 32000;
	var cs; if (c >= 31999) cs = ".."; else cs = string(c + 1);
	return "line " + string(1 + (p - c) / 32000) + ", col " + cs;
}
