package extensions
import rl "vendor:raylib"

/* Right-Click needs to know if you're hovered over a button.
 * If so then detects if you used the right mouse button instead of left.
 * Params:
 *    - rect: rl.Rectangle
 * Output:
 *    - Boolean indicating if the mouse is within rect.
 */
rl_right_clicked :: proc(rect: rl.Rectangle) -> int {

    return (rl.IsMouseButtonPressed(.RIGHT) && rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)) ? 2 : 0
}

/* Long-Press Detection:
 * - When the left button is pressed within 'rect', the state changes from idle to pressed and records the time.
 * - While in the pressed state, if the left button is held and the elapsed time exceeds the threshold,
 *   the state is set to long_pressed and the function returns true.
 * - If the mouse is released before the threshold, or leaves the rect (if you choose to cancel the press), the state resets.
 *
 * Params:
 *    - rect: rl.Rectangle, the region to monitor for a long-press.
 *    - threshold: float, the required duration (in seconds) for a long-press (default 1.0s).
 * Output:
 *    - Boolean indicating if a long-press event is detected.
 */
 // Define an enum for our long-press state
 LongPressState :: enum {
     idle,
     pressed,
     long_pressed,
 }

 // Global state variables for long-press detection
 lp_state: LongPressState = .idle
 lp_start_time: f64 = 0
 rl_long_press :: proc(rect: rl.Rectangle, threshold:= f64(1.0)) -> int {
     in_rect := rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)

     switch lp_state {
     case .idle:
         // Start long-press detection when left button is pressed within the rect.
         if in_rect && rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
             lp_state = .pressed
             lp_start_time = rl.GetTime()
         }
     case .pressed:
         // Cancel if the mouse leaves the rect or the button is released.
         if !(in_rect && rl.IsMouseButtonDown(rl.MouseButton.LEFT)) {
             lp_state = .idle
         } else if (rl.GetTime() - lp_start_time) >= threshold {
             lp_state = .long_pressed
         }
     case .long_pressed:
         // Continue to return true while the button is held && the mouse is inside.
         if !(in_rect && rl.IsMouseButtonDown(rl.MouseButton.LEFT)) {
             lp_state = .idle
         }
         return 4
     }

     return 0
 }