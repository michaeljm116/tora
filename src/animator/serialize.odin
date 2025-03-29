package animator

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"


save_animated_model :: proc(anim_model : AnimatedModel)
{
    data, err := json.marshal(anim_model)
    if err != nil{
        fmt.eprintln("Error marshaling JSON: ", err)
        return
    }
    defer delete(data)
    name := fmt.tprintf("%s.json",anim_model.model.name)
    os.write_entire_file(name, data)
}