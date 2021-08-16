var dialog_width = room_width * 0.6;
var prompt_height = string_height_ext(prompt, -1, dialog_width);
var dialog_height = prompt_height + 10;
var option_count = array_length(options);
for (var i = 0; i < option_count; i++) {
	option_heights[i] = string_height_ext(options[i], -1, dialog_width);
	dialog_height += 5 + option_heights[i];
}
//
var dialog_x = (room_width - dialog_width) div 2;
var dialog_y = (room_height - dialog_height) div 2;
var dialog_right = dialog_x + dialog_width;
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(dialog_x - 5, dialog_y - 5, dialog_right + 5, dialog_y + dialog_height + 5, 0);
//
draw_set_color(c_white);
draw_set_alpha(1);
draw_text_ext(dialog_x, dialog_y, prompt, -1, dialog_width);
var option_y = dialog_y + prompt_height + 15;
var option_clicked = -1;
for (var i = 0; i < option_count; i++) {
	var option_bot = option_y + option_heights[i];
	var option_over = point_in_rectangle(mouse_x, mouse_y, dialog_x, option_y, dialog_right, option_bot);
	if (option_over && mouse_check_button_pressed(mb_left)) option_clicked = i;
	draw_set_alpha(option_over ? 0.3 : 0.1);
	draw_rectangle(dialog_x, option_y, dialog_right, option_bot, false);
	draw_set_alpha(1);
	draw_text_ext(dialog_x, option_y, options[i], -1, dialog_width);
	option_y += 5 + option_heights[i];
}
if (option_clicked != -1) {
	if (txr_thread_resume(thread, option_clicked) == txr_thread_status.error) {
		show_debug_message(thread[txr_thread.result]);
	}
	instance_destroy();
}