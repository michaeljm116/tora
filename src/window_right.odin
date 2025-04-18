package main

import rl "vendor:raylib"

right_window := rl.Rectangle{left_window.x + left_window.width, left_window.y, left_window.width, left_window.height}
right_window_text := []cstring{"Model View" , "Animation View"}

draw_right_window :: proc()
{
    rl.GuiPanel(right_window, right_window_text[window_text_index])
	for s in model_creator.model.sprites {
		rl.DrawTexturePro(txtr, s.src, s.dst, s.origin, s.rotation, rl.WHITE)
		if(show_sprite_icon.active){
		  rl.DrawRectangleLinesEx(s.dst, 4, rl.BLACK)
		}
	}
}