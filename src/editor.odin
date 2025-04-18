package main

import rl "vendor:raylib"
import str "core:strings"
import ex "extensions"
import anim "animator"
// Global Constants
bot_size := f32(100)
left_size := f32(196)
right_size := f32(16)
top_size := rl.Vector2{32, 32}

right_panel := rl.Rectangle{window_size.x - right_size, 0, right_size, window_size.y}
bottom_panel := rl.Rectangle{0, window_size.y - bot_size, window_size.x, bot_size}
left_panel := rl.Rectangle{0, 0, left_size, window_size.y}
top_panel := rl.Rectangle{0, 0, window_size.x, top_size.y}

model_creator : anim.Model
model_viewer : anim.Model
anim_creator : anim.Model
anim_viewer : anim.Model
curr_pose : anim.Pose
txtr : rl.Texture2D


window_size := rl.Vector2{1280, 720}
window_text_index := 0
view_it := true


update_editor_gui :: proc()
{
    window_text_index = viewer_icon.active ? 1 : 0
    change_layer_order(&model_creator)
}

draw_editor_gui :: proc()
{
    rl.DrawRectangleRec(right_panel, rl.DARKGRAY)
    rl.DrawRectangleRec(bottom_panel, rl.DARKGRAY)

    draw_left_window()
    draw_right_window()
    draw_left_panel(&model_creator)
    draw_top_panel()
    draw_tool_tip()
}
