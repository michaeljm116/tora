package animator

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"


save_animated_model :: proc(anim_model : AnimatedModel)
{
    opt : json.Marshal_Options = {pretty = true}
    data, err := json.marshal(anim_model, opt)
    if err != nil{
        fmt.eprintln("Error marshaling JSON: ", err)
        return
    }
    defer delete(data)
    name := fmt.tprintf("%s/%s.json","assets/",anim_model.model.name)
    os.write_entire_file(name, data)
}

import_animated_model :: proc(path: string) -> AnimatedModel {
    data, ok := os.read_entire_file(path)
    if !ok {
        fmt.eprintln("Error reading file")
        return AnimatedModel{}
    }
    defer delete(data)

    anim_model: AnimatedModel
    uerr := json.unmarshal(data, &anim_model)
    if uerr != nil {
        fmt.eprintln("Error unmarshaling JSON:", uerr)
        return AnimatedModel{}
    }
    return anim_model
}