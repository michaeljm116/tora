package animator

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"

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