package main

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

b_select_sprite := false
pick_sprite_state := PickSpriteState.None
offset : rl.Vector2
sprite_rect : rl.Rectangle
box_rect : rl.Rectangle
rect_start: rl.Vector2
rect_end: rl.Vector2

PickSpriteState :: enum {
	None,
	FirstClick,
	ClickNRelease,
	ClickNDrag,
	BoxDrawn,
	DragBox
}

select_sprite :: proc(txtr: rl.Texture2D, sprites : []Sprite) {
	mouse_pos := rl.GetMousePosition()
	switch (pick_sprite_state)
	{
	case .None:
		if(rl.IsMouseButtonPressed(.LEFT) && is_in_window(mouse_pos, left_window)){
			rect_start = mouse_pos
			pick_sprite_state = .FirstClick}
	case .FirstClick:
		draw_dot(rect_start)
		if(is_in_window(mouse_pos, left_window)){
			if(rl.IsMouseButtonReleased(.LEFT)){pick_sprite_state = .ClickNRelease}
			if(rl.IsMouseButtonDown(.LEFT)){pick_sprite_state = .ClickNDrag}
		}else{
			if(rl.IsMouseButtonPressed(.LEFT)){pick_sprite_state = .None}
		}
	case .ClickNRelease:
		draw_dot(rect_start)
		if(rl.IsMouseButtonPressed(.LEFT) && is_in_window(mouse_pos, left_window)){
			rect_end = mouse_pos
			pick_sprite_state = .BoxDrawn
		}
	case .ClickNDrag:
		draw_dot(rect_start)
		if(is_in_window(mouse_pos, left_window)){
			if(rl.IsMouseButtonDown(.LEFT)){
				draw_transparent(rect_start, mouse_pos)
			}else if(rl.IsMouseButtonReleased(.LEFT)){
				rect_end = mouse_pos
				pick_sprite_state = .BoxDrawn
				sprite_rect = rl.Rectangle{rect_start.x, rect_start.y, rect_end.x - rect_start.x, rect_end.y - rect_start.y}
				box_rect = rl.Rectangle{rect_start.x, rect_start.y, rect_end.x, rect_end.y}
				pick_sprite_state = .BoxDrawn
			}
		}else{
			if(rl.IsMouseButtonDown(.LEFT)){
				draw_transparent(rect_start, window_clamp_opt(mouse_pos, left_window))
			}
			if(rl.IsMouseButtonReleased(.LEFT)){
				rect_end = window_clamp_opt(mouse_pos, left_window)
				sprite_rect = rl.Rectangle{rect_start.x, rect_start.y, rect_end.x - rect_start.x, rect_end.y - rect_start.y}
				box_rect = rl.Rectangle{rect_start.x, rect_start.y, rect_end.x, rect_end.y}
				pick_sprite_state = .BoxDrawn
			}
		}
	case .BoxDrawn:
		draw_rect_lines(rect_start, rect_end)
		if(rl.IsMouseButtonPressed(.LEFT))
		{
			in_box := is_in_window(mouse_pos, box_rect)
			if(in_box){
				pick_sprite_state = .DragBox
				offset = mouse_pos - rect_start
			}
			else{
				pick_sprite_state = .None}
		}
	case .DragBox:
		src,dst := draw_rect_lines_w_sprite(txtr, mouse_pos - offset, {sprite_rect.width, sprite_rect.height})
		if(rl.IsMouseButtonPressed(.LEFT)){
			if(is_in_window(mouse_pos - offset, right_window)){
				sprite := Sprite{src = src, dst = dst}
				//optimize_sprite(&sprite, txtr)
				sprite.name = fmt.tprintf("New Sprite(%i)", len(sprites))
				append(sprites^, sprite)
				pick_sprite_state = .None
			}
			else{
				pick_sprite_state = .None
			}
		}
	}
}

is_in_window :: proc(mouse_pos: rl.Vector2, window: rl.Rectangle) -> bool {
	if (mouse_pos.x > window.x &&
		   mouse_pos.x < window.x + window.width &&
		   mouse_pos.y > window.y &&
		   mouse_pos.y < window.y + window.height) {
		return true
	} else {
		return false
	}
}

// If you are outside of window, this clamps to the edge of the window
window_clamp :: proc(mouse_pos: rl.Vector2, window: rl.Rectangle) -> rl.Vector2 {
	ret := mouse_pos
	if(mouse_pos.x < window.x){ ret.x = window.x}
	else if(ret.x > window.x + window.width) {ret.x = window.x + window.width}
	if(mouse_pos.y < window.y){ret.y = window.y}
	else if(ret.y > window.y + window.height) {ret.y = window.y + window.height}
	return ret
}

// use opt if you KNOW you're not in the window
window_clamp_opt :: proc(mouse_pos: rl.Vector2, window: rl.Rectangle) -> rl.Vector2 {
	ret : rl.Vector2
	if(mouse_pos.x < window.x){ ret.x = window.x}
	else {ret.x = window.x + window.width}
	if(mouse_pos.y < window.y){ret.y = window.y}
	else {ret.y = window.y + window.height}
	return ret
}

optimize_sprite :: proc(sprite: ^Sprite, texture: rl.Texture2D) {
    // Load texture image data
    img := rl.LoadImageFromTexture(texture)
    pixels := rl.LoadImageColors(img)

    // Ensure valid pixels were loaded
    if pixels == nil {
        rl.UnloadImage(img)
        return
    }

    src := sprite.src
    tex_width := int(img.width)
    tex_height := int(img.height)

    // Bounds for the new cropped area
    min_x, min_y : int = int(src.x + src.width), int(src.y + src.height)
    max_x, max_y : int = int(src.x), int(src.y)

    // Scan for non-transparent pixels
    for y := int(src.y); y < int(src.y + src.height); y += 1 {
        for x := int(src.x); x < int(src.x + src.width); x += 1 {
            index := y * tex_width + x
            color := pixels[index]

            if color.a > 0 { // If pixel is not fully transparent
                if x < min_x { min_x = x; }
                if x > max_x { max_x = x; }
                if y < min_y { min_y = y; }
                if y > max_y { max_y = y; }
            }
        }
    }

    // If nothing was found, keep original size
    if max_x <= min_x || max_y <= min_y {
        rl.UnloadImageColors(pixels)
        rl.UnloadImage(img)
        return
    }

    // Calculate new size
    new_width := max_x - min_x + 1
    new_height := max_y - min_y + 1

    // Update sprite source rectangle
    sprite.src = rl.Rectangle{ x = cast(f32)min_x, y = cast(f32)min_y, width = cast(f32)new_width, height = cast(f32)new_height }

    // Adjust origin proportionally
    sprite.origin.x -= (cast(f32)min_x - src.x)
    sprite.origin.y -= (cast(f32)min_y - src.y)

    // Cleanup
    rl.UnloadImageColors(pixels)
    rl.UnloadImage(img)
}

