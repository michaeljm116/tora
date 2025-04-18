package animator

import rl "vendor:raylib"

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