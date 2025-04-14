package animator
import rl "vendor:raylib"

TopMenuIcon :: struct{
    rect : rl.Rectangle,
    active : bool,
    color : rl.Color,
    icon : rl.GuiIconName
}

place_icon_next_to :: proc(icon : ^TopMenuIcon, prev_rect : rl.Rectangle, is_right := true ){
    icon.rect = { prev_rect.x + prev_rect.width, prev_rect.y, prev_rect.width, prev_rect.height}
}

viewer_rect        := rl.Rectangle{0,0,top_size.x * 2, top_size.y}
save_rect        := rl.Rectangle{viewer_rect.x + viewer_rect.width, 0, top_size.x, top_size.y}
load_rect        := rl.Rectangle{save_rect.x + save_rect.width, 0, top_size.x, top_size.y}
play_rect        := rl.Rectangle{load_rect.x + load_rect.width,0, top_size.x, top_size.y}
pause_rect       := rl.Rectangle{play_rect.x  + play_rect.width,  0, top_size.x, top_size.y}
stop_rect        := rl.Rectangle{pause_rect.x + pause_rect.width, 0, top_size.x, top_size.y}
drag_rect        := rl.Rectangle{stop_rect.x + stop_rect.width, 0, top_size.x, top_size.y}
pos_rect         := rl.Rectangle{drag_rect.x + drag_rect.width, 0, top_size.x, top_size.y}
rot_rect         := rl.Rectangle{pos_rect.x + pos_rect.width, 0, top_size.x, top_size.y}
scale_rect       := rl.Rectangle{rot_rect.x + rot_rect.width, 0, top_size.x, top_size.y}
origin_rect      := rl.Rectangle{scale_rect.x + scale_rect.width, 0, top_size.x, top_size.y}
show_sprite_rect := rl.Rectangle{origin_rect.x + origin_rect.width, 0, top_size.x, top_size.y}
pose_rect        := rl.Rectangle{show_sprite_rect.x + show_sprite_rect.width, 0, top_size.x, top_size.y}

viewer_icon      := TopMenuIcon{rect = viewer_rect, active = false, color = rl.WHITE,icon = .ICON_PHOTO_CAMERA}
save_icon        := TopMenuIcon{rect = save_rect, active = false, color = rl.BLACK,icon = .ICON_FILE_SAVE_CLASSIC}
load_icon        := TopMenuIcon{rect = load_rect, active = false, color = rl.BLACK,icon = .ICON_FOLDER_FILE_OPEN}
play_icon        := TopMenuIcon{rect = play_rect, active = false, color = rl.GREEN,icon = .ICON_PLAYER_PLAY}
pause_icon       := TopMenuIcon{rect = pause_rect, active = false, color = rl.YELLOW,icon = .ICON_PLAYER_PAUSE}
stop_icon        := TopMenuIcon{rect = stop_rect, active = false, color = rl.RED,icon = .ICON_PLAYER_STOP}
drag_icon        := TopMenuIcon{rect = drag_rect, active = false, color = rl.PURPLE,icon = .ICON_CURSOR_HAND}
pos_icon         := TopMenuIcon{rect = pos_rect, active = false, color = rl.BLUE,icon = .ICON_TARGET_MOVE}
rot_icon         := TopMenuIcon{rect = rot_rect, active = false, color = rl.BLUE,icon = .ICON_ROTATE}
scale_icon       := TopMenuIcon{rect = scale_rect, active = false, color = rl.BLUE,icon = .ICON_SCALE}
origin_icon      := TopMenuIcon{rect = origin_rect, active = false, color = rl.BLUE, icon = .ICON_TARGET}
show_sprite_icon := TopMenuIcon{rect = show_sprite_rect, active = false, color = rl.BLACK,icon = .ICON_BOX}
pose_icon        := TopMenuIcon{rect = pose_rect, active = false, color = rl.BLACK,icon = .ICON_FILE_SAVE}

draw_icon_button :: proc(icon : ^TopMenuIcon, pixel_size := i32(2)) -> int
{
    prev_active := icon^.active
    rl.GuiToggle(icon.rect, "", &icon.active)
    active := bool(icon^.active)
    ret := int(prev_active != active)

    color := active?  icon.color : rl.GRAY

    rl.GuiDrawIcon(icon.icon, i32(icon.rect.x), i32(icon.rect.y), pixel_size, color)
    return ret
}

tooltip_active := true
tooltip_text : cstring = ""
draw_icon_button_tt :: proc(icon : ^TopMenuIcon, tooltip: cstring, pixel_size := i32(2)) -> int
{
    ret := draw_icon_button(icon, pixel_size)
    mouse_pos := rl.GetMousePosition()
    new_tt := rl.CheckCollisionPointRec(mouse_pos, icon.rect)
    if new_tt {
        tooltip_text = tooltip
        tooltip_active = true
    }
    return ret
}
draw_tool_tip :: proc()
{
    if(tooltip_active){
        mouse_pos := rl.GetMousePosition()
        text_width := rl.MeasureText(tooltip_text, 10)
        tooltip_box := rl.Rectangle{mouse_pos.x + 10, mouse_pos.y + 10, f32(text_width + 8), 20}
        rl.DrawRectangleRec(tooltip_box, rl.DARKGRAY)
        rl.DrawText(tooltip_text, i32(tooltip_box.x + 4), i32(tooltip_box.y + 4), 10, rl.WHITE)
        tooltip_active = false
    }
}