//! This treevent is fired when a key is typed, pressed or released on the keyboard.
//! It is a low-level event, which isn't suited for text input, but instead for raw key handling.
//! When a key is pressed BOTH an event with the .down action and one with the .press action (afterwards)
//! will be fired. The latter may be repeated if the key is held down afterwards.
const Widget = @import("../widget.zig").Widget;

const key = @import("../key.zig");

pub const Action = enum {
    down,
    up,

    /// Fired for a key being "pressed". This may be repeated when a key is held down.
    press,
};

action: Action,
scancode: key.Scancode,
modifiers: key.Modifiers,

const KeyPress = @This();

pub fn dispatch(self: KeyPress, widget: *Widget) !void {
    for (widget.children()) |child| {
        try child.treevent(self);
    }
}
