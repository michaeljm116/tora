/** ------------------ LEFT PANEL ------------------ **\
** This panel is for the selection of individual sprites
** Clicking on one  will display its properties
** And allow you to edit them as well as its layer order
\** ------------------ LEFT PANEL ------------------ **/

package main
import rl "vendor:raylib"
import anim "animator"
import ex "extensions"
import str "core:strings"

left_panel := rl.Rectangle{0, 0, left_size, window_size.y}
lp_padding : f32 = 4
lp_spacing : f32 = 24
lp_template := rl.Rectangle{left_panel.x + lp_padding, top_size.y + lp_padding, left_size - lp_padding * 2, lp_spacing}
curr_sprite := 0
curr_y := f32(-1.0)
green_seethrough := rl.Color{ 0, 228, 48, 49}

//model_name := "New Model"
editing_model_name := false
draw_left_panel :: proc(anim_model : anim.Model)
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

	if(len(sprites) > 0 && editing_name) do	name_the_sprite(sprites[:], curr_sprite)
	if(editing_model_name ) do name_it(&name)
}

// change layer order,
// if the number of sprites is greater than 1 poll for user input of either up or down if up then swap the array elements up and vv
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
name_the_sprite :: proc(sprites : []anim.Sprite, index: int)
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

name_it :: proc(name : ^string)
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
