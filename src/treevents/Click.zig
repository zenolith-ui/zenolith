//! This treevent is fired on a mouse click. The default dispatcher dispatches it to all Widgets.
//! Widgets that wish to handle being clicked on must ensure the click has occured on them.
//! The isOnWidget function allows this. This approach allows for widgets like sliders to detect
//! mouse up events anywhere in the UI.
const Position = @import("../layout/Position.zig");
const Rectangle = @import("../layout/Rectangle.zig");
const Widget = @import("../widget.zig").Widget;

/// A mouse button. For scroll_* buttons, only the click action is permitted.
pub const MouseButton = enum {
    left,
    middle,
    right,
    scroll_up,
    scroll_down,
    scroll_left,
    scroll_right,
};

pub const Action = enum {
    /// The mouse button has been pressed.
    down,

    /// The mouse button has been released.
    up,

    /// The mouse button has been pressed. This should indicate a single interaction with the GUI.
    /// Widgets should use this to handle a single mouse input, this is what a button reacts to
    /// for example. Platforms often fire this at the same time as a down event.
    click,
};

pos: Position,
button: MouseButton,
action: Action,

const Click = @This();

pub fn dispatch(self: Click, widget: *Widget) !void {
    for (widget.children()) |child| {
        try child.treevent(self);
    }
}

pub fn isOnWidget(self: Click, widget: Widget) bool {
    const bb = Rectangle{ .pos = widget.data.position, .size = widget.data.size };
    return bb.contains(self.pos);
}
