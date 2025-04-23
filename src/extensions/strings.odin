package extensions
import str "core:strings"
import "core:mem"
import "core:math"

string16 :: struct {
    data: [15]u8,
    len: u8
}

s16_to_cstr :: proc(from : string16) -> (to:cstring)
{
    cpy := from
    mem.copy(&to, &cpy.data, int(cpy.len))
    return
}
str_to_s16 :: proc(src: string) -> string16 {
   result: string16;
   n := min(len(src), 15);
   for i in 0..<n {
       result.data[i] = src[i];
   }
   result.len = u8(n);
   return result;
}

make_s16 :: proc(data : cstring) -> (to:string16)
{
    cpy := data
    count := min(len(data), 14)
    mem.copy(&to, &cpy, count)
    return
}
clear_s16 :: proc(s16 : ^string16)
{
   s16.data = {}
   s16.len = 0
}

// Fixed-size string for up to 23 bytes (not null-terminated by default)
string24 :: struct {
    data: [23]u8,
    len:  u8,
}

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