/** ------------------ TOP PANEL ------------------ **\
** OBV things like file save options etc is going here
** But also many of the edit functions will go here too
\** ------------------ TOP PANEL ------------------ **/
package main

import rl "vendor:raylib"
import str "core:strings"
import ex "extensions"
import anim "animator"


draw_top_panel :: proc()
{
	rl.DrawRectangleRec(top_panel, rl.DARKGRAY)
	draw_file_menu()
	handle_save_menu(&model_creator)
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
    if(draw_icon_button_tt(&pose_icon,"Save Pose")) > 0 do anim.save_pose(&model_viewer, &curr_pose)

    handle_transforms(&model_creator)
}

handle_save_menu :: proc(anim_model : ^anim.Model)
{
    if(save_icon.active){
        anim_model.texture_path = "assets/animation-test.png"
        for &s in anim_model.sprites{
            s.dst.x -= right_window.x
        }
        anim.save_model(anim_model)
        save_icon.active = false
    }
}

model_loaded := false
handle_model_loading :: proc()
{
    if(viewer_icon.active && !model_loaded)
    {
        model_viewer = anim.import_model("assets/Full_Model.json")
        model_loaded = true
        anim_creator = model_viewer
        //sprites = make([dynamic]Sprite, len(model_viewer.model.sprites))
        //copy(sprites[:], model_viewer.model.sprites[:])
    }
}

handle_transforms :: proc(anim_model : ^anim.Model)
{
    using anim_model
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