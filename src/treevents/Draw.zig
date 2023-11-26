//! This event signals widgets that they should be drawn using the given painter.
const Painter = @import("../painter.zig").Painter;
const Widget = @import("../widget.zig").Widget;

painter: *Painter,

const Draw = @This();

pub fn dispatch(self: Draw, widget: *Widget) !void {
    for (widget.children()) |child| {
        try child.treevent(self);
    }
}
