package main
import rl "vendor:raylib"
import math "core:math/linalg"
import "core:os"
import "core:encoding/json"
import "core:fmt"
import anim "animator"

test_texture : rl.Texture2D
test_sprite : Sprite
test_pose : Pose

main :: proc()
{
    //load the json
    data, ok := os.read_entire_file_from_filename("assets/test_model.json")
    if !ok{
        fmt.eprintln("Failed to load the file!")
        return
    }
    defer delete(data)

    // pasre the json
    json_data, err := json.parse(data)
    if err != .None{
        fmt.eprintln("Failed to parse the json file.")
        fmt.eprintln("Error:", err)
        return
    }
    defer json.destroy_value(json_data)

    // access the data
    root := json_data.(json.Object)
    fmt.println("name",
        root["name"],
        "num_parts:",
        root["num_parts"]
    )
    num_parts := root["num_parts"]
    rects : [dynamic]rl.Rectangle
    for pa in root["parts"].(json.Array)
    {
        p := pa.(json.Array)
        name := p[0]
        layer := i32(p[1].(json.Float))
        rect := rl.Rectangle{f32(p[2].(json.Float)),f32(p[3].(json.Float)),f32(p[4].(json.Float)),f32(p[5].(json.Float))}
        append(&rects, rect)
    }

    //begin scene
    rl.InitWindow(i32(anim.window_size.x), i32(anim.window_size.y), "2D Odin Raylib Animator")
    rl.SetTargetFPS(120)

    test_texture = rl.LoadTexture("assets/animation-test.png")
    test_sprite = Sprite{{256,256}, {205,211}, {30,40}, {205,211}, {2,2}, {102.5, 105.5}, 0, "head", 0}
    test_pose = Pose{{512,512}, {3,3}, {102.5,105.5}, 90, "head", 1}

    for(!rl.WindowShouldClose())
    {
        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKGRAY)

        //animate(&test_sprite, test_pose)
        //draw_sprite(test_sprite)

        anim.render(test_texture)

        rl.EndDrawing()
    }
}

/*load_model :: proc(path :cstring) -> (ModelData,bool)
{
    //load the json
    data, ok := os.read_entire_file_from_filename(path)
    if !ok{
        fmt.eprintln("Failed to load the file!")
        return ModelData, false
    }
    defer delete(data)

    // pasre the json
    json_data, err := json.parse(data)
    if err != .None{
        fmt.eprintln("Failed to parse the json file.")
        fmt.eprintln("Error:", err)
        return false
    }
    defer json.destroy_value(json_data)

    // access the data
    root := json_data.(json.Object)
    fmt.println("name",
        root["name"],
        "num_parts:",
        root["num_parts"]
    )
    num_parts := root["num_parts"].(json.Integer)
    rects : [dynamic]rl.Rectangle
    for pa in root["parts"].(json.Array)
    {
        p := pa.(json.Array)
        name := p[0]
        layer := i32(p[1].(json.Float))
        rect := rl.Rectangle{f32(p[2].(json.Float)),f32(p[3].(json.Float)),f32(p[4].(json.Float)),f32(p[5].(json.Float))}
        append(&rects, rect)
    }
    model_data := ModelData{
        name = root["name"].(json.String),
    }
    for i in 0..<num_parts{
        model_data.sprites[i] := Sprite{}
    }

}*/

ModelData :: struct
{
    name : string,
    sprites : []SpriteData,
    texture : rl.Texture2D
}
SpriteData :: struct
{
    name : cstring,
    src : rl.Rectangle,
    layer : u8
}

Model :: struct
{
    name : string,
    pos_w : rl.Vector2,
    sca_w : rl.Vector2,
    rot_w : f32,
    sprites : [dynamic]Sprite
}

Sprite :: struct
{
    pos_world : rl.Vector2,
    size_world : rl.Vector2,
    pos_txtr : rl.Vector2,
    size_txtr : rl.Vector2,
    scale : rl.Vector2,
    origin : rl.Vector2,
    rotation : f32,
    name : string,
    layer : u8
}

Frame :: struct
{
    model : Model,
    sprites : [dynamic]string,
    posses : [dynamic]Key
}

Key :: struct
{
    pos_1 : rl.Vector2,
    sca_l : rl.Vector2,
    org_l : rl.Vector2,
    rot_l : f32,
    time : f32
}

Pose :: struct
{
    pos : rl.Vector2,
    sca : rl.Vector2,
    org : rl.Vector2,
    rot : f32,
    name : string,
    time :  f32
}

animate :: proc(sprite: ^Sprite, pose : Pose)
{
    single_time := rl.GetFrameTime()
    double_time := rl.Vector2{single_time, single_time}

    sprite.pos_world = math.lerp(sprite.pos_world, pose.pos, double_time)
    sprite.scale = math.lerp(sprite.scale, pose.sca, double_time)
    sprite.rotation = math.lerp(sprite.rotation, pose.rot, single_time)
}

draw_sprite :: proc(sprite: Sprite)
{
    src := rl.Rectangle{sprite.pos_txtr.x, sprite.pos_txtr.y, sprite.size_txtr.x, sprite.size_txtr.y}
    dst := rl.Rectangle{sprite.pos_world.x, sprite.pos_world.y, sprite.size_world.x * sprite.scale.x, sprite.size_world.y * sprite.scale.y}

    rl.DrawTexturePro(test_texture, src, dst, sprite.origin, sprite.rotation, rl.WHITE)

}

draw_model :: proc(model: ^Model)
{
    for s in model.sprites{
        draw_sprite(s)
    }
}


render :: proc()
{
    pos_world := rl.Vector2{256, 256}
    pos_txtr := rl.Vector2{30,40}
    size_txtr := rl.Vector2{205,211}
    scale := rl.Vector2{2, 2}
    sca_world := size_txtr * scale

    dst := rl.Rectangle{pos_world.x, pos_world.y, sca_world.x, sca_world.y}
    src := rl.Rectangle{pos_txtr.x, pos_txtr.y, size_txtr.x, size_txtr.y}
    origin := rl.Vector2{size_txtr.x, size_txtr.y}

    rl.DrawTexturePro(test_texture, src, dst, origin, 0, rl.WHITE)
}
