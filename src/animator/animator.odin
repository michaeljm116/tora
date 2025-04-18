package animator

import rl "vendor:raylib"
import ex "../extensions"

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
save_pose :: proc(model : ^Model, pose_sprites : []Sprite){
    pose : Pose
    for &ps, i in pose_sprites {
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