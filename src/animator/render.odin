package animator

import rl "vendor:raylib"

window_size := rl.Vector2{1280, 720}
left_window := rl.Rectangle{left_panel.x + left_panel.width, top_panel.y + top_panel.height, (window_size.x - left_panel.width - right_panel.width) / 2, (window_size.y - top_panel.height - bottom_panel.height)}
right_window := rl.Rectangle{left_window.x + left_window.width, left_window.y, left_window.width, left_window.height}

view_it := true

left_window_text := []cstring{"Source Texture", "Model View"}
right_window_text := []cstring{"Model View" , "Animation View"}
window_text_index := 0

render :: proc(txtr: rl.Texture2D) {
	square := rl.Rectangle{1100, 100, 100, 100}
	rl.GuiEnable()
	window_text_index = viewer_icon.active ? 1 : 0
	rl.GuiPanel(left_window, left_window_text[window_text_index])
	rl.GuiPanel(right_window, right_window_text[window_text_index])

	if(!viewer_icon.active) do draw_texture(txtr)
	else do draw_model(temp_model, txtr)
	for s in sprites {
		rl.DrawTexturePro(txtr, s.src, s.dst, s.origin, s.rotation, rl.WHITE)
		if(show_sprite_icon.active){
		  rl.DrawRectangleLinesEx(s.dst, 4, rl.BLACK)
		}
	}
	rl.DrawRectangleRec(right_panel, rl.DARKGRAY)
	rl.DrawRectangleRec(bottom_panel, rl.DARKGRAY)
	update_editor_gui()
	draw_editor_gui()
}

draw_model :: proc (model: AnimatedModel, txtr: rl.Texture2D)
{
    for sprite in model.model.sprites
    {
        rl.DrawTexturePro(txtr, sprite.src, sprite.dst, sprite.origin, sprite.rotation, rl.WHITE)
    }
}

draw_texture :: proc(txtr: rl.Texture2D)
{
    txtr_rec_src := rl.Rectangle{0, 0, f32(txtr.width), f32(txtr.height)}
	txtr_rec_dst := rl.Rectangle {
		left_window.x,
		left_window.y,
		left_window.width,
		left_window.height,
	}

	rl.DrawTexturePro(txtr, txtr_rec_src, txtr_rec_dst, {0, 0}, 0, rl.WHITE)
	if(drag_icon.active) do select_sprite(txtr)
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
