package animator

import rl "vendor:raylib"
import str "core:strings"

// Global Constants
top_size := rl.Vector2{32, 32}
bot_size := f32(100)
left_size := f32(196)
right_size := f32(16)

top_panel := rl.Rectangle{0, 0, window_size.x, top_size.y}
left_panel := rl.Rectangle{0, 0, left_size, window_size.y}
right_panel := rl.Rectangle{window_size.x - right_size, 0, right_size, window_size.y}
bottom_panel := rl.Rectangle{0, window_size.y - bot_size, window_size.x, bot_size}

update_editor_gui :: proc()
{
    change_layer_order()
}

draw_editor_gui :: proc()
{
    draw_left_panel()
    draw_top_panel()
}

/** ------------------ LEFT PANEL ------------------ **\
** This panel is for the selection of individual sprites
** Clicking on one  will display its properties
** And allow you to edit them as well as its layer order
\** ------------------ LEFT PANEL ------------------ **/
lp_padding : f32 = 4
lp_spacing : f32 = 24
lp_template := rl.Rectangle{left_panel.x + lp_padding, top_size.y + lp_padding, left_size - lp_padding * 2, lp_spacing}
curr_sprite := 0

draw_left_panel :: proc()
{
	rl.DrawRectangleRec(left_panel, rl.GRAY)
	temp_rec := lp_template
	set_size_and_color(i32(lp_spacing), I32COLOR_WHITE)
	for s, i in sprites
	{
        if rl.GuiLabelButton(temp_rec, str.clone_to_cstring(s.name)){
            curr_sprite = i
        }
    	temp_rec.y += lp_spacing
	}
	set_default_gui()
	if(len(sprites) > 0) do	name_the_sprite(curr_sprite)
}

// change layer order,
// if the number of sprites is greater than 1 poll for user input of either up or down if up then swap the array elements up and vv
// if down then swap the array elements down and vv
change_layer_order :: proc()
{
    if len(sprites) > 1
    {
        if rl.IsKeyPressed(.UP) do swap_up(sprites, &curr_sprite)
        else if rl.IsKeyPressed(.DOWN) do swap_down(sprites, &curr_sprite)
    }
}

editing_name := true
name_the_sprite :: proc(index: int)
{
    sprite := &sprites[index]
    name_buf := str.clone_to_cstring(sprite.name)

    input_rect := rl.Rectangle{
        x = left_panel.x,
        y = window_size.y - 32,
        width = left_panel.width,
        height = 32,
    };
    secret := false
    result := rl.GuiTextBox(input_rect, name_buf, 128, editing_name)
    /* rl.GuiTextInputBox(input_rect,
        "Name Sprite",               // title
        "Enter new sprite name:",    // message
        "Save",                      // button text
        name_buf,                    // pointer to the buffer
        128,                         // maximum text length
        &secret
    )*/

    if result != true{
        sprite.name = str.clone_from_cstring(name_buf)
    }
}

/** ------------------ TOP PANEL ------------------ **\
** OBV things like file save options etc is going here
** But also many of the edit functions will go here too
\** ------------------ TOP PANEL ------------------ **/

draw_top_panel :: proc()
{
	rl.DrawRectangleRec(top_panel, rl.DARKGRAY)
	draw_file_menu()
}

TopMenuIcon :: struct{
    rect : rl.Rectangle,
    active : bool,
    color : rl.Color,
    icon : rl.GuiIconName
}

place_icon_next_to :: proc(icon : ^TopMenuIcon, prev_rect : rl.Rectangle, is_right := true ){
    icon.rect = { prev_rect.x + prev_rect.width, prev_rect.y, prev_rect.width, prev_rect.height}
}

save_rect := rl.Rectangle{0,0,top_size.x, top_size.y}
load_rect := rl.Rectangle{save_rect.x + save_rect.width, 0, top_size.x, top_size.y}
play_rect  := rl.Rectangle{dropdown_rect.width,0, top_size.x, top_size.y}
pause_rect := rl.Rectangle{play_rect.x  + play_rect.width,  0, top_size.x, top_size.y}
stop_rect  := rl.Rectangle{pause_rect.x + pause_rect.width, 0, top_size.x, top_size.y}
drag_rect  := rl.Rectangle{stop_rect.x + stop_rect.width, 0, top_size.x, top_size.y}
pos_rect   := rl.Rectangle{drag_rect.x + drag_rect.width, 0, top_size.x, top_size.y}
rot_rect   := rl.Rectangle{pos_rect.x + pos_rect.width, 0, top_size.x, top_size.y}
scale_rect := rl.Rectangle{rot_rect.x + rot_rect.width, 0, top_size.x, top_size.y}
show_sprite_rect := rl.Rectangle{scale_rect.x + scale_rect.width, 0, top_size.x, top_size.y}

save_icon := TopMenuIcon{rect = save_rect, active = false,color = rl.BLACK,icon = .ICON_FILE_SAVE}
load_icon := TopMenuIcon{rect = load_rect, active = false,color = rl.BLACK,icon = .ICON_FILE_OPEN}
play_icon := TopMenuIcon{rect = play_rect, active = false,color = rl.GREEN,icon = .ICON_PLAYER_PLAY}
pause_icon := TopMenuIcon{rect = pause_rect, active = false,color = rl.YELLOW,icon = .ICON_PLAYER_PAUSE}
stop_icon := TopMenuIcon{rect = stop_rect, active = false,color = rl.RED,icon = .ICON_PLAYER_STOP}
drag_icon := TopMenuIcon{rect = drag_rect, active = false,color = rl.PURPLE,icon = .ICON_TARGET}
pos_icon := TopMenuIcon{rect = pos_rect, active = false,color = rl.BLUE,icon = .ICON_TARGET_MOVE}
rot_icon := TopMenuIcon{rect = rot_rect, active = false,color = rl.BLUE,icon = .ICON_ROTATE}
scale_icon := TopMenuIcon{rect = scale_rect, active = false,color = rl.BLUE,icon = .ICON_SCALE}
show_sprite_icon := TopMenuIcon{rect = show_sprite_rect, active = false,color = rl.BLACK,icon = .ICON_SCALE}

fileselection := i32(0)
dropdown_rect := rl.Rectangle{0,0, 128, top_size.y}
b_save := false
b_play := false
b_pos := false
b_rot := false
b_scale := false
b_pause := false
b_stop := false
b_drag := false
b_show_sprite_rect := false

draw_file_menu :: proc()
{
    rl.GuiSetIconScale(1)
    rl.GuiDropdownBox(dropdown_rect,"File", &fileselection, false)
    draw_icon_button(rl.GuiIconName.ICON_PLAYER_PLAY, i32(play_rect.x), i32(play_rect.y), 2, rl.GREEN, rl.GRAY, &b_play)
    draw_icon_button(rl.GuiIconName.ICON_PLAYER_PAUSE, i32(pause_rect.x), i32(pause_rect.y), 2, rl.YELLOW, rl.GRAY, &b_pause)
    draw_icon_button(rl.GuiIconName.ICON_PLAYER_STOP, i32(stop_rect.x), i32(stop_rect.y), 2, rl.RED, rl.GRAY, &b_stop)
    if(draw_icon_button_tt(rl.GuiIconName.ICON_TARGET, i32(drag_rect.x), i32(drag_rect.y), 2, rl.PURPLE, rl.GRAY, &b_drag, "Select an object") > 0){
        pick_sprite_state = .None
    }
    handle_transforms()
    draw_icon_button_tt(rl.GuiIconName.ICON_BOX, i32(show_sprite_rect.x), i32(show_sprite_rect.y), 2, rl.BLACK, rl.GRAY, &b_show_sprite_rect, "Show Box around sprite")
}

handle_transforms :: proc()
{
    if(draw_icon_button_tt(rl.GuiIconName.ICON_TARGET_MOVE, i32(pos_rect.x), i32(pos_rect.y), 2, rl.BLUE, rl.GRAY, &b_pos, "Translate Sprite") > 0){
        b_rot, b_scale = false, false
    }
    else if(draw_icon_button_tt(rl.GuiIconName.ICON_ROTATE, i32(rot_rect.x), i32(rot_rect.y), 2, rl.BLUE, rl.GRAY, &b_rot, "Rotate Sprite") > 0){
        b_pos, b_scale = false, false
    }
    else if(draw_icon_button_tt(rl.GuiIconName.ICON_SCALE, i32(scale_rect.x), i32(scale_rect.y), 2, rl.BLUE, rl.GRAY, &b_scale, "Scale Sprite") > 0){
        b_pos, b_rot = false, false
    }
    if(len(sprites) > 0)
    {
        sprite := &sprites[curr_sprite]
        if(b_pos)
        {
            if(rl.IsKeyDown(.W)){sprite.dst.y -= 1}
            if(rl.IsKeyDown(.S)){sprite.dst.y += 1}
            if(rl.IsKeyDown(.A)){sprite.dst.x -= 1}
            if(rl.IsKeyDown(.D)){sprite.dst.x += 1}
        }
        if(b_rot){
            if(rl.IsKeyDown(.A)){sprite.rotation -= 1}
            if(rl.IsKeyDown(.D)){sprite.rotation += 1}
        }
        if(b_scale)
        {
            if(rl.IsKeyDown(.W)){sprite.dst.height += 1}
            if(rl.IsKeyDown(.S)){sprite.dst.height -= 1}
            if(rl.IsKeyDown(.A)){sprite.dst.width -= 1}
            if(rl.IsKeyDown(.D)){sprite.dst.width += 1}
        }
    }
}

draw_icon_button :: proc(icon_id : rl.GuiIconName, x, y, pixel_size : i32, active_color, inactive_color : rl.Color, active : ^bool) -> i32
{
   rect := rl.Rectangle{f32(x),f32(y),f32(16 * pixel_size), f32(16 * pixel_size)}
   ret := rl.GuiToggle(rect,"",active)
   color := active^ ? active_color : inactive_color
   rl.GuiDrawIcon(icon_id, x, y, pixel_size, color)
   return ret
}

draw_icon_button_tt :: proc(icon_id : rl.GuiIconName, x, y, pixel_size : i32,
                          active_color, inactive_color : rl.Color, active : ^bool,
                          tooltip: cstring) -> i32 {
    // Define button rectangle
    rect := rl.Rectangle{f32(x), f32(y), f32(16 * pixel_size), f32(16 * pixel_size)}
    ret := rl.GuiToggle(rect, "", active)
    color := active^ ? active_color : inactive_color
    rl.GuiDrawIcon(icon_id, x, y, pixel_size, color)

    // Get current mouse position
    mouse_pos := rl.GetMousePosition()
    if rl.CheckCollisionPointRec(mouse_pos, rect) {
        // Measure tooltip text width (assumes a font size of 10)
        text_width := rl.MeasureText(tooltip, 10)
        // Create a background rectangle for the tooltip with some padding
        tooltip_box := rl.Rectangle{mouse_pos.x + 10, mouse_pos.y + 10, f32(text_width + 8), 20}
        // Draw a dark background for readability
        rl.DrawRectangleRec(tooltip_box, rl.DARKGRAY)
        // Draw the tooltip text over it
        rl.DrawText(tooltip, i32(tooltip_box.x + 4), i32(tooltip_box.y + 4), 10, rl.WHITE)
    }
    return ret
}

/// Swap Up, This proc takes a sprite array and its index and does a swap with the previous element
swap_up :: proc(sprite_array : [dynamic]Sprite, curr_sprite : ^int)
{
    index := curr_sprite^
    if index > 0 {
        sprite_array[index], sprite_array[index - 1] = sprite_array[index - 1], sprite_array[index]
        curr_sprite^ = index - 1
    }
}

/// Swap Down, This proc takes a sprite array and its index and does a swap with the next element
swap_down :: proc(sprite_array : [dynamic]Sprite, curr_sprite : ^int)
{
    index := curr_sprite^
    if index < len(sprite_array) - 1 {
        sprite_array[index], sprite_array[index + 1] = sprite_array[index + 1], sprite_array[index]
        curr_sprite^ = index + 1
    }
}

/// Sprite Mouse Detection, if the mouse is over the sprite and the sprite is selected
/// set that sprite as selected
sprite_mouse_detection :: proc(sprite_array : [dynamic]Sprite, curr_sprite : ^int)
{
}

