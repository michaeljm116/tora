package main

import rl "vendor:raylib"
import str "core:strings"
import ex "extensions"
// Global Constants
top_size := rl.Vector2{32, 32}
bot_size := f32(100)
left_size := f32(196)
right_size := f32(16)

top_panel := rl.Rectangle{0, 0, window_size.x, top_size.y}
right_panel := rl.Rectangle{window_size.x - right_size, 0, right_size, window_size.y}
bottom_panel := rl.Rectangle{0, window_size.y - bot_size, window_size.x, bot_size}

update_editor_gui :: proc()
{
    change_layer_order()
}

draw_editor_gui :: proc()
{
    draw_left_window()
    draw_right_window()
    draw_left_panel()
    draw_top_panel()
    draw_tool_tip()
}
