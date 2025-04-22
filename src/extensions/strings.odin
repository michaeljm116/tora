package extensions
import str "core:strings"

copy_str_to_buf128 :: proc(src: string, buf: ^[128]u8) {
    count := copy_from_string(buf^[:], src)
    buf^[count] = 0
}

copy_str_to_buf64 :: proc(src: string, buf: ^[64]u8) {
    count := copy_from_string(buf^[:], src)
    buf^[count] = 0
}

copy_str_to_buf32 :: proc(src: string, buf: ^[32]u8) {
    count := copy_from_string(buf^[:], src)
    buf^[count] = 0
}

copy_str_to_buf :: proc{copy_str_to_buf128, copy_str_to_buf64, copy_str_to_buf32}


buf_to_str_128 ::  proc(model_buf: ^[128]u8) -> string {
   return str.clone(string(cstring(&model_buf^[0])))
}

buf_to_str_64 ::  proc(model_buf: ^[64]u8) -> string {
   return str.clone(string(cstring(&model_buf^[0])))
}

buf_to_str_32 ::  proc(model_buf: ^[32]u8) -> string {
   return str.clone(string(cstring(&model_buf^[0])))
}

buf_to_str :: proc{buf_to_str_128, buf_to_str_64, buf_to_str_32}