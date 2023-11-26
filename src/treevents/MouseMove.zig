//! This treevent is fired when the mouse cursor moves. It contains the new mouse cursor position
//! as well as the relative movement of the cursor.
const Position = @import("../layout/Position.zig");
const Rectangle = @import("../layout/Rectangle.zig");
const Widget = @import("../widget.zig").Widget;

pos: Position,
dx: isize,
dy: isize,

const MouseMove = @This();

pub fn dispatch(self: MouseMove, widget: *Widget) !void {
    for (widget.children()) |child| {
        try child.treevent(self);
    }
}

pub fn isOnWidget(self: MouseMove, widget: Widget) bool {
    const bb = Rectangle{ .pos = widget.data.position, .size = widget.data.size };
    return bb.contains(self.pos);
}
