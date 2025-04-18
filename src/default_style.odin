package main
import rl "vendor:raylib"

TEXT_SIZE :: i32(rl.GuiDefaultProperty.TEXT_SIZE)
TEXT_COLOR :: i32(rl.GuiControlProperty.TEXT_COLOR_NORMAL)
I32COLOR_WHITE := transmute(i32)u32(0xFFFFFFFF)
I32COLOR_RED := transmute(i32)u32(0xFF0000FF)

DefaultStyle :: struct
{
    text_size : i32,
    text_color : i32
}
default_gui : DefaultStyle
init_default_style:: proc()
{
    default_gui.text_size = rl.GuiGetStyle(.DEFAULT, TEXT_SIZE)
    default_gui.text_color = rl.GuiGetStyle(.DEFAULT, TEXT_COLOR)
}
set_default_style :: proc()
{
    rl.GuiSetStyle(.DEFAULT, TEXT_COLOR, default_gui.text_color)
    rl.GuiSetStyle(.DEFAULT, TEXT_SIZE, default_gui.text_size)
}
set_size_and_color :: proc(size, color : i32){
    rl.GuiSetStyle(.DEFAULT, TEXT_SIZE, size)
    rl.GuiSetStyle(.DEFAULT, TEXT_COLOR, color)
}