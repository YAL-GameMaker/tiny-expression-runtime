function txr_print_pos(argument0) {
	var p = argument0;
	var c = p % 32000;
	var cs; if (c >= 31999) cs = ".."; else cs = string(c + 1);
	return "line " + string(1 + (p - c) / 32000) + ", col " + cs;
}
