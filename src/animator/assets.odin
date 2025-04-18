package animator

import rl "vendor:raylib"


//curr_model : anim.Model
//sprites: [dynamic]Sprite

model_creator : Model
model_viewer : Model
anim_creator : Model
anim_viewer : Model

Sprite :: struct
{
	name:     string,
	src:      rl.Rectangle,
	dst:      rl.Rectangle,
	origin:   rl.Vector2,
	rotation: f32,
	color:    rl.Color,
	layer:    u8,
}

Transform :: struct
{
	origin:   rl.Vector2,
	position: rl.Vector2,
	scale:    rl.Vector2,
	rotation: f32,
	pad:      u32,
}

Pose :: struct{
	name: string,
	sprites: [dynamic]Sprite,
}

Model :: struct
{
    name:         string,
	sprites:      [dynamic]Sprite,
	poses:        [dynamic]Pose,
	has_anim:     bool,
	texture_path: string,
	trans_w: Transform
	//anims : [dynamic]Animation,
}
