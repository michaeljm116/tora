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