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
    draw_tool_tip()
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
curr_y := f32(-1.0)
green_seethrough := rl.Color{ 0, 228, 48, 49}
draw_left_panel :: proc()
{
	rl.DrawRectangleRec(left_panel, rl.GRAY)
	temp_rec := lp_template
	set_size_and_color(i32(lp_spacing), I32COLOR_WHITE)
	for s, i in sprites
	{
        if rl.GuiLabelButton(temp_rec, str.clone_to_cstring(s.name)){
            curr_sprite = i
            editing_name = !editing_name
            curr_y = temp_rec.y
        }
    	temp_rec.y += lp_spacing
	}
	if(curr_y >= 0){
	temp_rec.y = curr_y
	rl.DrawRectangleRec(temp_rec, green_seethrough)}
	set_default_gui()
	if(len(sprites) > 0 && editing_name) do	name_the_sprite(curr_sprite)
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

editing_name := false
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
	handle_save_menu()
	handle_model_loading()
}

fileselection := i32(0)
dropdown_rect := rl.Rectangle{0,0, 128, top_size.y}

draw_file_menu :: proc()
{
    rl.GuiSetIconScale(1)
    draw_icon_button_tt(&viewer_icon, "Switch between Texture and Model viewer")
    draw_icon_button(&load_icon)
    draw_icon_button(&save_icon)
    draw_icon_button(&play_icon)
    draw_icon_button(&pause_icon)
    draw_icon_button(&stop_icon)
    draw_icon_button_tt(&show_sprite_icon,"Show Box around sprite")
    if(draw_icon_button_tt(&drag_icon,"Select an object") > 0) do pick_sprite_state = .None
    if(draw_icon_button_tt(&pose_icon,"Save Pose")) > 0 do anim_save_pose(&curr_model, sprites[:])
    
    handle_transforms()
}

anim_model_name := ""
handle_save_menu :: proc()
{
    if(save_icon.active){
        //if anim_model_name == ""
        {
            secret := false
            name_buf := str.clone_to_cstring(anim_model_name)
            input_rect := rl.Rectangle{
                x = left_panel.x,
                y = 132,
                width = left_panel.width,
                height = 132,
            }
            rl.GuiTextInputBox(input_rect,
                "Name Sprite",               // title
                "Enter new sprite name:",    // message
                "Save",                      // button text
                name_buf,                    // pointer to the buffer
                128,                         // maximum text length
                &secret
            )
            anim_model_name = str.clone_from_cstring(name_buf)
        }
        anim_model := AnimatedModel{
            model = {
                name = "model",
                trans_w = {
                    scale = {1,1}
                },
                sprites = sprites
            },
            has_anim = false,
            texture_path = "assets/animation-test.png"
        }

        for &s in sprites{
            s.dst.x -= right_window.x
        }
        save_animated_model(anim_model)
        save_icon.active = false
    }
}

model_loaded := false
temp_model : AnimatedModel
handle_model_loading :: proc()
{
    if(viewer_icon.active && !model_loaded)
    {
        temp_model = import_animated_model("assets/Full_Model.json")
        model_loaded = true
        sprites = make([dynamic]Sprite, len(temp_model.model.sprites))
        copy(sprites[:], temp_model.model.sprites[:])
    }
}

handle_transforms :: proc()
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

    if(len(sprites) > 0)
    {
        sprite := &sprites[curr_sprite]
        if(pos_icon.active)
        {
            if(rl.IsKeyDown(.W)){sprite.dst.y -= 1}
            if(rl.IsKeyDown(.S)){sprite.dst.y += 1}
            if(rl.IsKeyDown(.A)){sprite.dst.x -= 1}
            if(rl.IsKeyDown(.D)){sprite.dst.x += 1}
        }
        if(rot_icon.active){
            if(rl.IsKeyDown(.A)){sprite.rotation -= 1}
            if(rl.IsKeyDown(.D)){sprite.rotation += 1}
        }
        if(scale_icon.active)
        {
            if(rl.IsKeyDown(.W)){sprite.dst.height -= 1}
            if(rl.IsKeyDown(.S)){sprite.dst.height += 1}
            if(rl.IsKeyDown(.A)){sprite.dst.width -= 1}
            if(rl.IsKeyDown(.D)){sprite.dst.width += 1}
        }
        if(origin_icon.active)
        {
            rl.DrawCircle(i32(sprite.dst.x + sprite.origin.x), i32(sprite.dst.y + sprite.origin.y), 5, rl.BLACK)
            if(rl.IsKeyDown(.W)){sprite.origin.y -= 1}
            if(rl.IsKeyDown(.S)){sprite.origin.y += 1}
            if(rl.IsKeyDown(.A)){sprite.origin.x -= 1}
            if(rl.IsKeyDown(.D)){sprite.origin.x += 1}
        }
    }
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
