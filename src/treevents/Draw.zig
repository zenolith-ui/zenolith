//! This event signals widgets that they should be drawn using the given painter.
const zenolith = @import("../main.zig");

const Color = @import("../Color.zig");
const Painter = @import("../painter.zig").Painter;
const Size = @import("../layout/Size.zig");
const Widget = @import("../widget.zig").Widget;

painter: *Painter,

const Draw = @This();

pub fn dispatch(self: Draw, widget: *Widget) !void {
    for (widget.children()) |child| {
        try child.treevent(self);
        if (zenolith.debug_render) {
            const debug_size = Size{
                .width = @max(4, child.data.size.width),
                .height = @max(4, child.data.size.height),
            };

            try self.painter.strokeRect(
                .{ .pos = child.data.position, .size = debug_size },
                2,
                Color.fromInt(0x00ffffff),
                null,
            );
        }
    }
}
