package animator

import rl "vendor:raylib"

Sprite :: struct
{
    name : string,
    src : rl.Rectangle,
    dst : rl.Rectangle,
    origin : rl.Vector2,
    rotation : f32,
    color : rl.Color,
    layer : u8,

}