package extensions
import str "core:strings"
import "core:mem"
import "core:math"

string16 :: struct {
    data: [15]u8,
    len: u8
}

s16_to_cstr_c :: proc(from : string16) -> (to:cstring)
{
    cpy := from
    to = cstring(raw_data(cpy.data[:]))
    return
}
s16_to_cstr_p :: proc(from : ^string16) -> (to:cstring)
{
    to = cstring(raw_data(from.data[:]))
    return
}
s16_to_cstr :: proc{s16_to_cstr_c, s16_to_cstr_p}

str_to_s16_c :: proc(from: string) -> (to:string16) {
   n := min(len(from), 15)
   for i in 0..<n {
       to.data[i] = from[i]
   }
   to.len = u8(n)
   return
}

str_to_s16_p :: proc(to : ^string16, from:string)
{
   n := min(len(from),15)
   for i in 0..<n{
       to.data[i] = from[i]
   }
   to.len = u8(n)
}
str_to_s16 :: proc{str_to_s16_c, str_to_s16_p}
make_s16_c :: proc(data: cstring) -> (to:string16) {
   cpy := transmute([^]u8)data
   count := min(len(data), 15)
   mem.copy(&to.data, cpy, count)
   to.len = u8(count)
   return
}
make_s16_p :: proc(data: ^cstring) -> (to:string16) {
   count := min(len(data), 15)
   mem.copy(&to.data, data, count)
   to.len = u8(count)
   return
}
make_s16 :: proc{make_s16_c, make_s16_p}

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