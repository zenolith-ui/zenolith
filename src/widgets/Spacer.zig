//! A simple spacer that will take up a certain amount of space depending on the set mode.
const std = @import("std");

const treev = @import("../treevent.zig");

const Size = @import("../layout/Size.zig");
const Widget = @import("../widget.zig").Widget;

mode: Mode,

const Spacer = @This();

pub const Mode = union(enum) {
    /// The spacer will have an initial size of 0 but be flex-expanded with the given factor.
    /// This is often desirable when aligning widgets in Boxes.
    flex: u31,

    /// The spacer will be the given size, clamped to fit the constraints.
    fixed: Size,
};

pub fn init(alloc: std.mem.Allocator, mode: Mode) !*Widget {
    const self = Spacer{
        .mode = mode,
    };

    return try Widget.init(alloc, self);
}

pub fn treevent(self: *Spacer, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            selfw.data.size = tv.constraints.clamp(switch (self.mode) {
                .flex => .{ .width = 0, .height = 0 },
                .fixed => |s| s,
            });
        },

        else => try tv.dispatch(selfw),
    }
}

pub fn getFlexExpand(self: Spacer, selfw: Widget) u31 {
    _ = selfw;

    return switch (self.mode) {
        .flex => |f| f,
        .fixed => 0,
    };
}
