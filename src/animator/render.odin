package animator

import rl "vendor:raylib"

window_size := rl.Vector2{1280, 720}
left_window := rl.Rectangle{0, 0, 512, 512}
right_window := rl.Rectangle{512, 0, 512, 512}

view_it := true


render :: proc(txtr: rl.Texture2D) {
	square := rl.Rectangle{1100, 100, 100, 100}
	txtr_rec_src := rl.Rectangle{0, 0, f32(txtr.width), f32(txtr.height)}
	txtr_rec_dst := rl.Rectangle {
		left_window.x,
		left_window.y,
		left_window.width,
		left_window.height,
	}
	rl.GuiEnable()

	rl.GuiLabelButton({256, 256, 256, 256}, "HEllO")
	rl.GuiWindowBox(left_window, "idk what to say")
	rl.GuiWindowBox(right_window, "draawp me hurr plz")
	{
		rl.DrawTexturePro(txtr, txtr_rec_src, txtr_rec_dst, {0, 0}, 0, rl.WHITE)
		//rl.DrawRectangleGradientV(400, 50, 256, 256, rl.BLACK, rl.WHITE)
		rl.GuiLabel(square, "yoyoyo")
		if (rl.GuiButton(
				   square,
				   "draw rect",
			   )) {b_select_sprite = !b_select_sprite;pick_sprite_state = .None}
		if (b_select_sprite) {
			select_sprite(txtr)
		}

	}
	for s in sprites {
		rl.DrawTexturePro(txtr, s.src, s.dst, s.origin, s.rotation, rl.WHITE)
	}

	//rl.GuiTextInputBox(panel, "Name Box", "Enter Name", "buttons?", "whats tis?", 64, &view_it)
	//rl.GuiPanel(left_panel, "THIS IS A TEST PANEL")

	//rl.DrawRectangleRec(left_panel, rl.DARKGRAY)
	rl.DrawRectangleRec(right_panel, rl.DARKGRAY)
	//rl.DrawRectangleRec(top_panel, rl.DARKGRAY)
	rl.DrawRectangleRec(bottom_panel, rl.WHITE)
	//rl.GuiLine(bottom_panel, "WHAT IS A TEXT DOING HERE???")
	update_editor_gui()
	draw_editor_gui()
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
draw_rect_lines_w_sprite :: proc(
	txtr: rl.Texture2D,
	pos, size: rl.Vector2,
) -> (
	rl.Rectangle,
	rl.Rectangle,
) {
	ratio := rl.Vector2 {
		f32(txtr.width) / left_window.width,
		f32(txtr.height) / left_window.height,
	} //very unoptimal
	src := rl.Rectangle {
		rect_start.x * ratio.x,
		rect_start.y * ratio.y,
		size.x * ratio.x,
		size.y * ratio.y,
	}
	dst := rl.Rectangle{pos.x, pos.y, size.x, size.y}
	rl.DrawTexturePro(txtr, src, dst, {0, 0}, 0, rl.WHITE)
	rl.DrawRectangleLinesEx(dst, 4, rl.SKYBLUE)
	return src, dst
}
