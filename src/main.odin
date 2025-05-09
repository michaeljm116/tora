package main
import rl "vendor:raylib"
import math "core:math/linalg"
import "core:os"
import "core:encoding/json"
import "core:fmt"
import "core:strings"
import anim "animator"
import "core:mem"
import "base:intrinsics"

window_size := rl.Vector2{1280, 720}
bot_size := f32(128)
left_size := f32(196)
right_size := f32(16)
top_size := rl.Vector2{32, 32}
track_alloc: mem.Tracking_Allocator

main :: proc()
{
    // Memory tracker
	mem.tracking_allocator_init(&track_alloc, context.allocator)
	context.allocator = mem.tracking_allocator(&track_alloc)
	defer leak_detection()
    //begin scene
    //rl.SetConfigFlags({rl.ConfigFlag.WINDOW_UNDECORATED})
    rl.InitWindow(i32(window_size.x), i32(window_size.y), "TwoD Odin Raylib Animator")
    rl.SetTargetFPS(120)
    init_default_style()


    recent_texture_path := load_recent_texture("../config.ini")
    curr_txtr = rl.LoadTexture("assets/animation-test.png")

    panels := Panels {
        right = rl.Rectangle{window_size.x - right_size, -1, right_size, window_size.y},
        bottom = rl.Rectangle{-1, window_size.y - bot_size, window_size.x, bot_size},
        left = rl.Rectangle{-1, 0, left_size, window_size.y},
        top = rl.Rectangle{-1, 0, window_size.x, top_size.y}
    }
    windows := Windows {
        left = Window{
            names = {"Source Texture","Model View","Anim Start"},
            size = {panels.left.x + panels.left.width,
            panels.top.y + panels.top.height,
            (window_size.x - panels.left.width - panels.right.width) / 2,
            (window_size.y - panels.top.height - panels.bottom.height)}
        },
        right = Window{
            names = {"Model View", "Pose View", "Anim Current"},
            size = {panels.left.x + panels.left.width + (window_size.x - panels.left.width - panels.right.width) / 2,
            panels.top.y + panels.top.height,
            (window_size.x - panels.left.width - panels.right.width) / 2,
            (window_size.y - panels.top.height - panels.bottom.height)}
        },
    }

    init_editor_gui(windows, panels)
    for(!rl.WindowShouldClose())
    {
        //update scene
        update_editor_gui()

        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKGRAY)
        rl.GuiEnable()

        draw_editor_gui(windows, panels)

        rl.EndDrawing()
    }
    shutdown()
}

leak_detection :: proc()
{
	fmt.eprintf("\n")
	for _, entry in track_alloc.allocation_map {
		fmt.eprintf("- %v leaked %v bytes\n", entry.location, entry.size)
	}
	for entry in track_alloc.bad_free_array {
		fmt.eprintf("- %v bad free\n", entry.location)
	}
	mem.tracking_allocator_destroy(&track_alloc)
	fmt.eprintf("\n")
	free_all(context.temp_allocator)
}


load_recent_texture :: proc(path: string) -> string {
    data, ok := os.read_entire_file(path)
    if !ok {
        fmt.eprintln("Config file not found:", path)
        return ""
    }
    defer delete(data)

    content := string(data)
    lines := strings.split(content, "\n")
    for line in lines {
        trimmed := strings.trim_space(line)
        if strings.has_prefix(trimmed, "recent_texture") {
            parts := strings.split(trimmed, "=")
            if len(parts) >= 2 {
                return strings.trim_space(parts[1])
            }
        }
    }
    return ""
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

}


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
*/