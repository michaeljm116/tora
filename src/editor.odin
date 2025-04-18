package main

import rl "vendor:raylib"
import str "core:strings"
import ex "extensions"
import anim "animator"
import "core:fmt"


model_creator : anim.Model
model_viewer : anim.Model
anim_creator : anim.Model
anim_viewer : anim.Model
curr_pose : anim.Pose
curr_txtr : rl.Texture2D

window_text_index := 0
view_it := true

EditorState :: enum
{
   Model,
   Pose,
   Anim
}
editor_state : EditorState = .Model

Panels :: struct
{
   right : rl.Rectangle,
   left : rl.Rectangle,
   top : rl.Rectangle,
   bottom : rl.Rectangle
}
Window :: struct
{
   names : [len(EditorState)]cstring,
   using size: rl.Rectangle
}
Windows :: struct
{
   left : Window,
   right : Window
}

//--------------------------------------------------------------------------------------------------------\\
// /Main
//--------------------------------------------------------------------------------------------------------\\
init_editor_gui :: proc(windows : Windows, panels : Panels)
{
    // Load config file here:
    lp_template = rl.Rectangle{panels.left.x + lp_padding, top_size.y + lp_padding, left_size - lp_padding * 2, lp_spacing}
}
update_editor_gui :: proc()
{
    window_text_index = int(editor_state)
    change_layer_order(&model_creator)
}

draw_editor_gui :: proc(windows : Windows, panels : Panels)
{
    //rl.DrawRectangleRec(right_panel, rl.DARKGRAY)
    //rl.DrawRectangleRec(bottom_panel, rl.DARKGRAY)

    draw_right_window(windows.right)
    draw_left_window(windows)
    draw_left_panel(panels.left,&model_creator)
    draw_top_panel(panels.top, windows.right)
    draw_tool_tip()
}

//--------------------------------------------------------------------------------------------------------\\
// /LeftWindow
//--------------------------------------------------------------------------------------------------------\\
draw_left_window :: proc(windows: Windows)
{
    rl.GuiPanel(windows.left.size, windows.left.names[window_text_index])

    #partial switch editor_state{
        case .Model: draw_texture(curr_txtr, windows)
        case .Pose: anim.draw_model(model_viewer, curr_txtr)
    }
}
draw_texture :: proc(txtr: rl.Texture2D, windows: Windows)
{
    txtr_rec_src := rl.Rectangle{0, 0, f32(txtr.width), f32(txtr.height)}
	txtr_rec_dst := windows.left.size
	rl.DrawTexturePro(txtr, txtr_rec_src, txtr_rec_dst, {0, 0}, 0, rl.WHITE)
	if(drag_icon.active) do select_sprite(txtr, &model_creator, windows)
}

//--------------------------------------------------------------------------------------------------------\\
// /RightWindow
//--------------------------------------------------------------------------------------------------------\\
draw_right_window :: proc(window: Window)
{
    rl.GuiPanel(window.size, window.names[window_text_index])
    #partial switch editor_state
    {
        case .Model:
            for s in model_creator.sprites {
      		rl.DrawTexturePro(curr_txtr, s.src, s.local.rect, s.origin, s.rotation, rl.WHITE) //TODO: Investigate: This draws local sprite...
      		if(show_sprite_icon.active){
        		  rl.DrawRectangleLinesEx(s.rect, 4, rl.BLACK)
          		}
           	}
        case .Pose:
            for s in curr_pose.sprites{
                rl.DrawTexturePro(curr_txtr, s.src, s.local.rect, s.origin, s.rotation, rl.WHITE) //TODO: Investigate: This draws local sprite...
          		if(show_sprite_icon.active){
        		  rl.DrawRectangleLinesEx(s.rect, 4, rl.BLACK)
          		}
            }
    }

}

//--------------------------------------------------------------------------------------------------------\\
// /TopPanel
//--------------------------------------------------------------------------------------------------------\\
draw_top_panel :: proc(top_panel : rl.Rectangle, right_window : Window)
{
	rl.DrawRectangleRec(top_panel, rl.DARKGRAY)
	draw_file_menu()
	handle_save_menu(&model_creator, right_window)
	handle_model_loading()
}

fileselection := i32(0)
dropdown_rect := rl.Rectangle{0,0, 128, top_size.y}

draw_file_menu :: proc()
{
    rl.GuiSetIconScale(1)
    if(draw_icon_button_tt(&mode_icon, "Switch between Texture and Model viewer") > 0) do toggle_mode()
    draw_icon_button(&load_icon)
    draw_icon_button(&save_icon)
    draw_icon_button(&play_icon)
    draw_icon_button(&pause_icon)
    draw_icon_button(&stop_icon)
    draw_icon_button_tt(&show_sprite_icon,"Show Box around sprite")
    if(draw_icon_button_tt(&drag_icon,"Select an object") > 0) do pick_sprite_state = .None
    if(draw_icon_button_tt(&pose_icon,"Save Pose")) > 0 do anim.save_pose(&model_viewer, &curr_pose)

    #partial switch editor_state
    {
        case .Model:
            if len(model_creator.sprites) > 0 do handle_transforms(&model_creator.sprites[curr_sprite])
        case .Pose:
            if len(curr_pose.sprites) > 0 do handle_transforms(&curr_pose.sprites[curr_sprite])
    }
}

toggle_mode :: proc()
{
    #partial switch editor_state
    {
        case .Model: editor_state = .Pose
        case .Pose: editor_state = .Model
    }
}

handle_save_menu :: proc(anim_model : ^anim.Model, right_window : Window)
{
    if(save_icon.active){
        anim_model.texture_path = "assets/animation-test.png"
        for &s in anim_model.sprites{
            s.local.position.x -= right_window.x
        }
        anim.save_model(anim_model)
        save_icon.active = false
    }
}

model_loaded := false
handle_model_loading :: proc()
{
    if(editor_state == .Pose && !model_loaded)
    {
        model_viewer = anim.import_model("assets/Full_Model.json")
        model_loaded = true
        anim_creator = model_viewer
        curr_pose.sprites = make([dynamic]anim.Sprite, len(model_viewer.sprites))
        copy(curr_pose.sprites[:], model_viewer.sprites[:])
    }
}

handle_transforms :: proc(sprite : ^anim.Sprite)
{
    if(draw_icon_button_tt(&pos_icon, "Translate Sprite") > 0){
        rot_icon.active, scale_icon.active, origin_icon.active = false, false, false
    }
    else if(draw_icon_button_tt(&rot_icon, "Rotate Sprite") > 0){
        pos_icon.active, scale_icon.active, origin_icon.active = false, false, false
    }
    else if(draw_icon_button_tt(&scale_icon, "Scale Sprite") > 0){
        pos_icon.active, rot_icon.active, origin_icon.active = false, false, false
    }
    else if(draw_icon_button_tt(&origin_icon, "Change Origin") > 0){
        pos_icon.active, rot_icon.active, scale_icon.active = false, false, false
    }
    transform_sprite(sprite)
}

transform_sprite :: proc (sprite : ^anim.Sprite)
{
    if(pos_icon.active)
    {
        if(rl.IsKeyDown(.W)){sprite.local.position.y -= 1}
        if(rl.IsKeyDown(.S)){sprite.local.position.y += 1}
        if(rl.IsKeyDown(.A)){sprite.local.position.x -= 1}
        if(rl.IsKeyDown(.D)){sprite.local.position.x += 1}
    }
    if(rot_icon.active){
        if(rl.IsKeyDown(.A)){sprite.local.rotation -= 1}
        if(rl.IsKeyDown(.D)){sprite.local.rotation += 1}
    }
    if(scale_icon.active)
    {
        if(rl.IsKeyDown(.W)){sprite.local.scale.y -= 1}
        if(rl.IsKeyDown(.S)){sprite.local.scale.y += 1}
        if(rl.IsKeyDown(.A)){sprite.local.scale.x -= 1}
        if(rl.IsKeyDown(.D)){sprite.local.scale.x += 1}
    }
    if(origin_icon.active)
    {
        rl.DrawCircle(i32(sprite.local.position.x + sprite.local.origin.x), i32(sprite.local.position.y + sprite.local.origin.y), 5, rl.BLACK)
        if(rl.IsKeyDown(.W)){sprite.local.origin.y -= 1}
        if(rl.IsKeyDown(.S)){sprite.local.origin.y += 1}
        if(rl.IsKeyDown(.A)){sprite.local.origin.x -= 1}
        if(rl.IsKeyDown(.D)){sprite.local.origin.x += 1}
    }
}
//--------------------------------------------------------------------------------------------------------\\
// /LeftPanel
//--------------------------------------------------------------------------------------------------------\\
lp_padding : f32 = 4
lp_spacing : f32 = 24
lp_template : rl.Rectangle
curr_sprite := 0
curr_y := f32(-1.0)
green_seethrough := rl.Color{ 0, 228, 48, 49}

editing_model_name := false
draw_left_panel :: proc(left_panel : rl.Rectangle, anim_model : ^anim.Model)
{
    using anim_model
    // Draw the background
	rl.DrawRectangleRec(left_panel, rl.GRAY)
	temp_rec := lp_template
	set_size_and_color(i32(lp_spacing), I32COLOR_WHITE)

	//First show the model name
	if(rl.GuiLabelButton(temp_rec, str.clone_to_cstring(name))){
	   curr_y = temp_rec.y
	}
	if(ex.rl_right_clicked(temp_rec) == 2) do editing_model_name = true
	temp_rec.y += lp_spacing

	//For each sprite, show the name
	//If name is clicked, set that to curr_sprite
	for s, i in sprites
	{
        if rl.GuiLabelButton(temp_rec, str.clone_to_cstring(s.name)){
            curr_sprite = i
            editing_name = false
            curr_y = temp_rec.y
        }
    	temp_rec.y += lp_spacing
	}
	// Highlight the current sprite
	if(curr_y >= 0){
    	temp_rec.y = curr_y
    	rl.DrawRectangleRec(temp_rec, green_seethrough)
	}

	// Reset the defaults
	set_default_style()

	// edit the name if... curr_sprite is rightclicked
	if(ex.rl_right_clicked(temp_rec) == 2){
	   editing_name = true
	}
	if(rl.IsKeyPressed(.ENTER)){
        editing_name = false
        editing_model_name = false
	}

	if(len(sprites) > 0 && editing_name) do	name_the_sprite(sprites[:], curr_sprite, left_panel)
	if(editing_model_name ) do name_it(&name, left_panel)
}

// change layer order,
// if the number of sprites is greater than 1
// then poll for user input of either up or down if up
// then swap the array elements up and vv
// if down then swap the array elements down and vv
change_layer_order :: proc(anim_model : ^anim.Model)
{
    using anim_model
    if len(sprites) > 1
    {
        if rl.IsKeyPressed(.UP) do swap_up(sprites, &curr_sprite)
        else if rl.IsKeyPressed(.DOWN) do swap_down(sprites, &curr_sprite)
    }
}

editing_name := false
name_the_sprite :: proc(sprites : []anim.Sprite, index: int, left_panel : rl.Rectangle)
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

    if result != true{
        sprite.name = str.clone_from_cstring(name_buf)
    }
}

name_it :: proc(name : ^string, left_panel : rl.Rectangle)
{
    name_buf := str.clone_to_cstring(name^)
    input_rect := rl.Rectangle{
        x = left_panel.x,
        y = window_size.y - 32,
        width = left_panel.width,
        height = 32,
    };
    secret := false
    result := rl.GuiTextBox(input_rect, name_buf, 128, editing_model_name)

    if result != true{
        name^ = str.clone_from_cstring(name_buf)
    }
}

/// Swap Up, This proc takes a sprite array and its index and does a swap with the previous element
swap_up :: proc(sprite_array : [dynamic]anim.Sprite, curr_sprite : ^int)
{
    index := curr_sprite^
    if index > 0 {
        sprite_array[index], sprite_array[index - 1] = sprite_array[index - 1], sprite_array[index]
        curr_sprite^ = index - 1
    }
}

/// Swap Down, This proc takes a sprite array and its index and does a swap with the next element
swap_down :: proc(sprite_array : [dynamic]anim.Sprite, curr_sprite : ^int)
{
    index := curr_sprite^
    if index < len(sprite_array) - 1 {
        sprite_array[index], sprite_array[index + 1] = sprite_array[index + 1], sprite_array[index]
        curr_sprite^ = index + 1
    }
}



//--------------------------------------------------------------------------------------------------------\\
// ?Icons
//--------------------------------------------------------------------------------------------------------\\

TopMenuIcon :: struct{
    rect : rl.Rectangle,
    active : bool,
    color : rl.Color,
    icon : rl.GuiIconName
}

place_icon_next_to :: proc(icon : ^TopMenuIcon, prev_rect : rl.Rectangle, is_right := true ){
    icon.rect = { prev_rect.x + prev_rect.width, prev_rect.y, prev_rect.width, prev_rect.height}
}

viewer_rect      := rl.Rectangle{0,0,top_size.x * 2, top_size.y}
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

mode_icon        := TopMenuIcon{rect = viewer_rect, active = false, color = rl.WHITE,icon = .ICON_PHOTO_CAMERA}
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

//--------------------------------------------------------------------------------------------------------\\
// /DefaultStyle
//--------------------------------------------------------------------------------------------------------\\
TEXT_SIZE :: i32(rl.GuiDefaultProperty.TEXT_SIZE)
TEXT_COLOR :: i32(rl.GuiControlProperty.TEXT_COLOR_NORMAL)
I32COLOR_WHITE := transmute(i32)u32(0xFFFFFFFF)
I32COLOR_RED := transmute(i32)u32(0xFF0000FF)

DefaultStyle :: struct
{
    text_size : i32,
    text_color : i32
}
default_gui : DefaultStyle
init_default_style:: proc()
{
    default_gui.text_size = rl.GuiGetStyle(.DEFAULT, TEXT_SIZE)
    default_gui.text_color = rl.GuiGetStyle(.DEFAULT, TEXT_COLOR)
}
set_default_style :: proc()
{
    rl.GuiSetStyle(.DEFAULT, TEXT_COLOR, default_gui.text_color)
    rl.GuiSetStyle(.DEFAULT, TEXT_SIZE, default_gui.text_size)
}
set_size_and_color :: proc(size, color : i32){
    rl.GuiSetStyle(.DEFAULT, TEXT_SIZE, size)
    rl.GuiSetStyle(.DEFAULT, TEXT_COLOR, color)
}

//--------------------------------------------------------------------------------------------------------\\
// /DragNDrop
//--------------------------------------------------------------------------------------------------------\\
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

select_sprite :: proc(txtr: rl.Texture2D, model : ^anim.Model, windows : Windows) {
	mouse_pos := rl.GetMousePosition()
	switch (pick_sprite_state)
	{
	case .None:
		if(rl.IsMouseButtonPressed(.LEFT) && is_in_window(mouse_pos, windows.left)){
			rect_start = mouse_pos
			pick_sprite_state = .FirstClick}
	case .FirstClick:
		draw_dot(rect_start)
		if(is_in_window(mouse_pos, windows.left)){
			if(rl.IsMouseButtonReleased(.LEFT)){pick_sprite_state = .ClickNRelease}
			if(rl.IsMouseButtonDown(.LEFT)){pick_sprite_state = .ClickNDrag}
		}else{
			if(rl.IsMouseButtonPressed(.LEFT)){pick_sprite_state = .None}
		}
	case .ClickNRelease:
		draw_dot(rect_start)
		if(rl.IsMouseButtonPressed(.LEFT) && is_in_window(mouse_pos, windows.left)){
			rect_end = mouse_pos
			pick_sprite_state = .BoxDrawn
		}
	case .ClickNDrag:
		draw_dot(rect_start)
		if(is_in_window(mouse_pos, windows.left)){
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
				draw_transparent(rect_start, window_clamp_opt(mouse_pos, windows.left))
			}
			if(rl.IsMouseButtonReleased(.LEFT)){
				rect_end = window_clamp_opt(mouse_pos, windows.left)
				sprite_rect = rl.Rectangle{rect_start.x, rect_start.y, rect_end.x - rect_start.x, rect_end.y - rect_start.y}
				box_rect = rl.Rectangle{rect_start.x, rect_start.y, rect_end.x, rect_end.y}
				pick_sprite_state = .BoxDrawn
			}
		}
	case .BoxDrawn:
		draw_rect_lines(rect_start, rect_end)
		if(rl.IsMouseButtonPressed(.LEFT))
		{
			in_box := rl.CheckCollisionPointRec(mouse_pos, box_rect)// is_in_window(mouse_pos, box_rect)
			if(in_box){
				pick_sprite_state = .DragBox
				offset = mouse_pos - rect_start
			}
			else{
				pick_sprite_state = .None}
		}
	case .DragBox:
		src,dst := draw_rect_lines_w_sprite(txtr, mouse_pos - offset, {sprite_rect.width, sprite_rect.height}, windows.left)
		if(rl.IsMouseButtonPressed(.LEFT)){
			if(is_in_window(mouse_pos - offset, windows.right)){
				sprite := anim.Sprite{src = src, rect = dst}
				//optimize_sprite(&sprite, txtr)
				sprite.name = fmt.tprintf("New Sprite(%i)", len(model.sprites))
				append(&model.sprites, sprite)
				pick_sprite_state = .None
			}
			else{
				pick_sprite_state = .None
			}
		}
	}
}

is_in_window :: proc(mouse_pos: rl.Vector2, window: Window) -> bool {
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
window_clamp :: proc(mouse_pos: rl.Vector2, window: Window) -> rl.Vector2 {
	ret := mouse_pos
	if(mouse_pos.x < window.x){ ret.x = window.x}
	else if(ret.x > window.x + window.width) {ret.x = window.x + window.width}
	if(mouse_pos.y < window.y){ret.y = window.y}
	else if(ret.y > window.y + window.height) {ret.y = window.y + window.height}
	return ret
}

// use opt if you KNOW you're not in the window
window_clamp_opt :: proc(mouse_pos: rl.Vector2, window: Window) -> rl.Vector2 {
	ret : rl.Vector2
	if(mouse_pos.x < window.x){ ret.x = window.x}
	else {ret.x = window.x + window.width}
	if(mouse_pos.y < window.y){ret.y = window.y}
	else {ret.y = window.y + window.height}
	return ret
}

optimize_sprite :: proc(sprite: ^anim.Sprite, texture: rl.Texture2D) {
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

draw_rect_lines_w_sprite :: proc(txtr: rl.Texture2D, pos, size: rl.Vector2, window: Window) -> (rl.Rectangle,rl.Rectangle)
{
	ratio := rl.Vector2 {
		f32(txtr.width) / window.width,
		f32(txtr.height) / window.height,
	} //very unoptimal
	src := rl.Rectangle {
		(rect_start.x - window.x) * ratio.x,
		(rect_start.y - window.y) * ratio.y,
		size.x * ratio.x,
		size.y * ratio.y,
	}
	dst := rl.Rectangle{pos.x, pos.y, size.x, size.y}
	rl.DrawTexturePro(txtr, src, dst, {0, 0}, 0, rl.WHITE)
	rl.DrawRectangleLinesEx(dst, 4, rl.SKYBLUE)
	return src, dst
};