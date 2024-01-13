//! Fired when a character is typed. This is similar to a KeyPress event,
//! except that the platform translates it into text input.
const Widget = @import("../widget.zig").Widget;

pub const ptrfire = true;

codepoint: u21,

/// Set this to true if you've handled the key event. It will stop postFire handling.
handled: bool = false,

const CharType = @This();

pub fn dispatch(self: *CharType, widget: *Widget) !void {
    for (widget.children()) |child| {
        try child.treevent(self);
    }
}
