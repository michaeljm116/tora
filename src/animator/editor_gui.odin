package animator

import rl "vendor:raylib"
import str "core:strings"

// Global Constants
top_size := f32(32)
bot_size := f32(100)
left_size := f32(196)
right_size := f32(100)

top_panel := rl.Rectangle{0, 0, window_size.x, top_size}
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
TEXT_SIZE :: i32(rl.GuiDefaultProperty.TEXT_SIZE)
TEXT_COLOR :: i32(rl.GuiControlProperty.TEXT_COLOR_NORMAL)
I32COLOR_WHITE := transmute(i32)u32(0xFFFFFFFF)
I32COLOR_RED := transmute(i32)u32(0xFF0000FF)

curr_sprite := 0
draw_left_panel :: proc()
{
	rl.DrawRectangleRec(left_panel, rl.GRAY)
	prev_y := top_size
	spacing := f32(24)
	padding : f32 = 4
	fs := rl.GuiGetStyle(.DEFAULT, TEXT_SIZE)
	fc := rl.GuiGetStyle(.DEFAULT, TEXT_COLOR)
	rl.GuiSetStyle(.DEFAULT, TEXT_SIZE, i32(spacing))
	rl.GuiSetStyle(.DEFAULT, TEXT_COLOR, I32COLOR_WHITE)
	for s, i in sprites
	{
        if rl.GuiLabelButton(rl.Rectangle{left_panel.x + padding, prev_y + spacing, left_size - padding * 2, spacing}, str.clone_to_cstring(s.name)){
            curr_sprite = i
        }
    	prev_y += spacing
	}
	rl.GuiSetStyle(.DEFAULT, TEXT_COLOR, fc)
	rl.GuiSetStyle(.DEFAULT, TEXT_SIZE, fs)
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

/** ------------------ TOP PANEL ------------------ **\
** OBV things like file save options etc is going here
** But also many of the edit functions will go here too
\** ------------------ TOP PANEL ------------------ **/
draw_top_panel :: proc()
{
	rl.DrawRectangleRec(top_panel, rl.DARKGRAY)
	draw_file_menu()
}

fileselection := i32(0)
dropdown_rect := rl.Rectangle{0,0, 128, top_size}
play_rect  := rl.Rectangle{dropdown_rect.width,0, 32, top_size}
pause_rect := rl.Rectangle{play_rect.x  + play_rect.width,  0, 32, top_size}
stop_rect  := rl.Rectangle{pause_rect.x + pause_rect.width, 0, 32, top_size}
drag_rect  := rl.Rectangle{stop_rect.x + stop_rect.width, 0, 32, top_size}

b_play := false
b_pause := false
b_stop := false
b_drag := false

draw_file_menu :: proc()
{
    rl.GuiSetIconScale(1)
    rl.GuiDropdownBox(dropdown_rect,"File", &fileselection, false)
    if(draw_icon_button(rl.GuiIconName.ICON_TARGET, i32(drag_rect.x), i32(drag_rect.y), 2, rl.PURPLE, rl.GRAY, &b_drag) > 0){
        pick_sprite_state = .None
    }
    draw_icon_button(rl.GuiIconName.ICON_PLAYER_PLAY, i32(play_rect.x), i32(play_rect.y), 2, rl.GREEN, rl.GRAY, &b_play)
    draw_icon_button(rl.GuiIconName.ICON_PLAYER_PAUSE, i32(pause_rect.x), i32(pause_rect.y), 2, rl.YELLOW, rl.GRAY, &b_pause)
    draw_icon_button(rl.GuiIconName.ICON_PLAYER_STOP, i32(stop_rect.x), i32(stop_rect.y), 2, rl.RED, rl.GRAY, &b_stop)
    
   }

draw_icon_button :: proc(icon_id : rl.GuiIconName, x, y, pixel_size : i32, active_color, inactive_color : rl.Color, active : ^bool) -> i32
{
   rect := rl.Rectangle{f32(x),f32(y),f32(16 * pixel_size), f32(16 * pixel_size)}
   ret := rl.GuiToggle(rect,"",active)
   color := active^ ? active_color : inactive_color
   rl.GuiDrawIcon(icon_id, x, y, pixel_size, color)
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

