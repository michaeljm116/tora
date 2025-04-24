package animator

import rl "vendor:raylib"
import ex "../extensions"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:encoding/json"
//--------------------------------------------------------------------------------------------------------\\
// /Assets
//--------------------------------------------------------------------------------------------------------\\
Sprite :: struct
{
	name:     ex.string16,
	src:      rl.Rectangle,
	using local:  Transform,
	color:    rl.Color,
	layer:    u8,
}

Pose :: struct{
	name: ex.string16,
	sprites: [dynamic]Sprite,
}

Model :: struct
{
    name:         ex.string16,
	sprites:      [dynamic]Sprite,
	poses:        [dynamic]Pose,
	has_anim:     bool,
	texture_path: string,
	trans_w: Transform
	//anims : [dynamic]Animation,
}

@private
RectTransform :: struct {
    position, scale: rl.Vector2
}

@private
PosScaleRect :: struct #raw_union {rect: rl.Rectangle, using _: RectTransform}
Transform :: struct {
    using _: PosScaleRect,
    origin:   rl.Vector2,
    rotation: f32
}


//--------------------------------------------------------------------------------------------------------\\
// /Draw
//--------------------------------------------------------------------------------------------------------\\
draw_model :: proc (model: Model, txtr: rl.Texture2D)
{
    trans := model.trans_w
    for sprite in model.sprites
    {
        world_rec := rl.Rectangle{
            sprite.local.position.x + trans.position.x,
            sprite.local.position.y + trans.position.y,
            sprite.local.scale.x * trans.scale.x,
            sprite.local.scale.y * trans.scale.y
        }
        rl.DrawTexturePro(txtr, sprite.src, world_rec, sprite.local.origin, sprite.local.rotation, rl.WHITE)
    }
}
draw_sprite :: proc (sprite : Sprite, txtr: rl.Texture2D){
   rl.DrawTexturePro(txtr, sprite.src, sprite.local.rect, sprite.local.origin, sprite.local.rotation, sprite.color)
}

draw_pose :: proc (pose : Pose, txtr: rl.Texture2D)
{
    for s in pose.sprites{
        rl.DrawTexturePro(txtr, s.src, s.local.rect, s.origin, s.rotation, rl.WHITE) //TODO: Investigate: This draws local sprite...
    }
}

//--------------------------------------------------------------------------------------------------------\\
// /Serialize
//--------------------------------------------------------------------------------------------------------\\
save_model :: proc(anim_model : Model)
{
    opt : json.Marshal_Options = {pretty = true}
    data, err := json.marshal(anim_model, opt)
    if err != nil{
        fmt.eprintln("Error marshaling JSON: ", err)
        return
    }
    defer delete(data)

    name := fmt.tprintf("%s/%s.json","assets/",ex.s16_to_cstr(anim_model.name))
    os.write_entire_file(name, data)
}

import_model :: proc(path: string) -> Model {
    data, ok := os.read_entire_file(path)
    if !ok {
        fmt.eprintln("Error reading file")
        return Model{}
    }
    defer delete(data)

    anim_model: Model
    uerr := json.unmarshal(data, &anim_model)
    if uerr != nil {
        fmt.eprintln("Error unmarshaling JSON:", uerr)
        return Model{}
    }
    return anim_model
}

/*
COMPARES THESE 4 things from sprite:
	dst:      rl.Rectangle,
	origin:   rl.Vector2,
	rotation: f32,
	color:    rl.Color,
If any chagnes, return true
*/
sprite_changed :: proc(src, dst : Sprite) -> bool {
    src_rect := src.rect
    dst_rect := dst.rect
    if src_rect.x != dst_rect.x || src_rect.y != dst_rect.y || src_rect.width != dst_rect.width || src_rect.height != dst_rect.height do return true
    if src.origin.x != dst.origin.x || src.origin.y != dst.origin.y do return true
    if src.rotation != dst.rotation do return true
    if src.color.r != dst.color.r || src.color.g != dst.color.g || src.color.b != dst.color.b || src.color.a != dst.color.a do return true
    return false
}

/*
goes through all the sprites in the src and dst,
and if any of them have changed
copy the dst to the src
also name the pose... which would require a text box to enter the name
*/
save_pose :: proc(model : ^Model, pose : ^Pose){
    pose : Pose
    for ps, i in pose.sprites {
        if sprite_changed(model.sprites[i], ps){
           append(&pose.sprites,ps)
        }
    }
    append(&model.poses, pose)
    model.has_anim = true
}

/*
Take a screenshot of the pose and make a small image of it
The pose is on the right-window so just render it to a texture
*/
create_pose_ss :: proc(model : Model, texture : rl.Texture2D, ss_size : rl.Vector2, window : rl.Rectangle) -> rl.Texture2D {

    rt := rl.LoadRenderTexture(i32(window.width), i32(window.height))

    rl.BeginTextureMode(rt)
    {
        rl.ClearBackground(rl.DARKGRAY)
        draw_model(model, texture)
    }
    rl.EndTextureMode()

    ss_img := rl.LoadImageFromTexture(rt.texture)
    rl.ImageResize(&ss_img, i32(ss_size.x), i32(ss_size.y))
    ss_tex := rl.LoadTextureFromImage(ss_img)

    // Clean up temporary resources.
    rl.UnloadImage(ss_img)
    rl.UnloadRenderTexture(rt)

    return ss_tex
}