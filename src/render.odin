package main

import rl "vendor:raylib"
import anim "animator"

window_size := rl.Vector2{1280, 720}

view_it := true

window_text_index := 0

render :: proc(txtr: rl.Texture2D) {
	square := rl.Rectangle{1100, 100, 100, 100}
	window_text_index = viewer_icon.active ? 1 : 0

	rl.DrawRectangleRec(right_panel, rl.DARKGRAY)
	rl.DrawRectangleRec(bottom_panel, rl.DARKGRAY)
}

draw_dot :: proc(position: rl.Vector2) {
	rl.DrawCircle(i32(position.x), i32(position.y), 4, rl.LIME)
}
draw_transparent :: proc(first, second: rl.Vector2) {
	rect := rl.Rectangle{first.x, first.y, second.x - first.x, second.y - first.y}
	rl.DrawRectanglePro(rect, {0, 0}, 0, rl.Color{25, 125, 125, 50})
}
draw_rect_lines :: proc(first, second: rl.Vector2) {
	rect := rl.Rectangle{first.x, first.y, second.x - first.x, second.y - first.y}
	rl.DrawRectangleLinesEx(rect, 4, rl.SKYBLUE)
}

draw_rect_lines_w_sprite :: proc(txtr: rl.Texture2D, pos, size: rl.Vector2) -> (rl.Rectangle,rl.Rectangle)
{
	ratio := rl.Vector2 {
		f32(txtr.width) / left_window.width,
		f32(txtr.height) / left_window.height,
	} //very unoptimal
	src := rl.Rectangle {
		(rect_start.x - left_window.x) * ratio.x,
		(rect_start.y - left_window.y) * ratio.y,
		size.x * ratio.x,
		size.y * ratio.y,
	}
	dst := rl.Rectangle{pos.x, pos.y, size.x, size.y}
	rl.DrawTexturePro(txtr, src, dst, {0, 0}, 0, rl.WHITE)
	rl.DrawRectangleLinesEx(dst, 4, rl.SKYBLUE)
	return src, dst
}
