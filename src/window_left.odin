package main
import rl "vendor:raylib"
import anim "animator"

left_window := rl.Rectangle{left_panel.x + left_panel.width, top_panel.y + top_panel.height, (window_size.x - left_panel.width - right_panel.width) / 2, (window_size.y - top_panel.height - bottom_panel.height)}
left_window_text := []cstring{"Source Texture", "Model View"}

draw_left_window :: proc()
{
    rl.GuiPanel(left_window, left_window_text[window_text_index])
    if(!viewer_icon.active) do draw_texture(txtr)
	else do anim.draw_model(model_viewer, txtr)

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
	if(drag_icon.active) do select_sprite(txtr, &model_creator)
}

