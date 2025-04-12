package animator

import rl "vendor:raylib"

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
curr_model : AnimatedModel
sprites: [dynamic]Sprite


Transform :: struct 
{
	origin:   rl.Vector2,
	position: rl.Vector2,
	scale:    rl.Vector2,
	rotation: f32,
	pad:      u32,
}

Model :: struct 
{
	name:    string,
	trans_w: Transform,
	sprites: [dynamic]Sprite,
}

Pose :: struct{
	name: string,
	sprites: [dynamic]Sprite,
}

AnimatedModel :: struct 
{
	model:        Model,
	poses:        [dynamic]Pose,
	has_anim:     bool,
	texture_path: string,
	//anims : [dynamic]Animation,
}
