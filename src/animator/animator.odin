package animator

import rl "vendor:raylib"
import ex "../extensions"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:encoding/json"

//--------------------------------------------------------------------------------------------------------\\
// ?Assets
//--------------------------------------------------------------------------------------------------------\\
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


//--------------------------------------------------------------------------------------------------------\\
// ?Draw
//--------------------------------------------------------------------------------------------------------\\
draw_model :: proc (model: Model, txtr: rl.Texture2D)
{
    trans := model.trans_w
    for sprite in model.sprites
    {
        dst := rl.Rectangle{
            sprite.dst.x + trans.position.x,
            sprite.dst.y + trans.position.y,
            sprite.dst.width * trans.scale.x,
            sprite.dst.height * trans.scale.y
        }
        rl.DrawTexturePro(txtr, sprite.src, dst, sprite.origin, sprite.rotation, rl.WHITE)
    }
}

draw_sprite :: proc (sprite : Sprite, txtr: ^rl.Texture2D){
   rl.DrawTexturePro(txtr^, sprite.src, sprite.dst, sprite.origin, sprite.rotation, sprite.color)
}

//--------------------------------------------------------------------------------------------------------\\
// ?Serialize
//--------------------------------------------------------------------------------------------------------\\
save_model :: proc(anim_model : ^Model)
{
    opt : json.Marshal_Options = {pretty = true}
    data, err := json.marshal(anim_model, opt)
    if err != nil{
        fmt.eprintln("Error marshaling JSON: ", err)
        return
    }
    defer delete(data)
    name := fmt.tprintf("%s/%s.json","assets/",anim_model.name)
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
    src_rect := src.dst
    dst_rect := dst.dst
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