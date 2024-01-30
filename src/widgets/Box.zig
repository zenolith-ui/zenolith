//! A widget which lays out it's children using a FlowBox-like algorithm in a given direction.
const std = @import("std");

const attreebute = @import("../attreebute.zig");
const treev = @import("../treevent.zig");
const layout = @import("../layout.zig");

const Widget = @import("../widget.zig").Widget;

pub const Direction = enum {
    vertical,
    horizontal,
};

/// Specifies how children should be aligned on the secondary axis.
/// In horizontal mode, left means top and right means bottom.
pub const ChildPositioning = enum {
    left,
    center,
    right,
};

pub const Child = struct {
    widget: *Widget,
    /// Offset from the start of the box. Used for positioning.
    offset: u31 = 0,

    pos: ChildPositioning,
};

/// Direction to lay out children in.
/// - vertical/column
/// - horizontal/row
direction: Direction,
children: std.MultiArrayList(Child),

/// If set to true, the box will expand in the direction orthogonal to the direction field
/// to fill the constraints.
orth_expand: bool = false,

const Box = @This();

pub fn init(alloc: std.mem.Allocator, direction: Direction) !*Widget {
    const self = Box{
        .direction = direction,
        .children = std.MultiArrayList(Child){},
    };

    return try Widget.init(alloc, self);
}

pub fn deinit(self: *Box, selfw: *Widget) void {
    self.children.deinit(selfw.data.allocator);
}

pub fn treevent(self: *Box, selfw: *Widget, tv: anytype) anyerror!void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            const slice = self.children.slice();

            // The maximum size of the children in the direction orthogonal to that of the Box.
            var max_orth_size: u31 = if (self.orth_expand) switch (self.direction) {
                .vertical => tv.constraints.max.width,
                .horizontal => tv.constraints.max.height,
            } else 0;
            var cur_pos: u31 = 0;

            // first pass, initial sizes
            {
                for (slice.items(.widget)) |child| {
                    var child_cons = layout.Constraints{
                        .max = tv.constraints.max,
                        .min = layout.Size.zero,
                    };
                    switch (self.direction) {
                        .vertical => {
                            child_cons.max.height -|= cur_pos;
                        },
                        .horizontal => {
                            child_cons.max.width -|= cur_pos;
                        },
                    }

                    try child.treevent(treev.LayoutSize{
                        .constraints = child_cons,
                        // we only do a second pass on this child if it's flex
                        .final = child.getFlexExpand() == 0,
                    });

                    cur_pos += switch (self.direction) {
                        .vertical => child.data.size.height,
                        .horizontal => child.data.size.width,
                    };

                    max_orth_size = @max(max_orth_size, switch (self.direction) {
                        .vertical => child.data.size.width,
                        .horizontal => child.data.size.height,
                    });
                }
            }

            // second pass, flex widgets
            {
                const remaining_space = switch (self.direction) {
                    .vertical => tv.constraints.max.height,
                    .horizontal => tv.constraints.max.width,
                } -| cur_pos;
                cur_pos = 0;

                const flex_extra_space = try selfw.data.allocator.alloc(?f64, self.children.len);
                defer selfw.data.allocator.free(flex_extra_space);
                @memset(flex_extra_space, null);

                var flex_sum: f64 = 0;
                for (slice.items(.widget)) |child| {
                    flex_sum += @floatFromInt(child.getFlexExpand());
                }

                // calculate the height/width the flex children will get.
                for (flex_extra_space, slice.items(.widget)) |*fes, child| {
                    if (child.getFlexExpand() > 0) {
                        fes.* = @as(f64, @floatFromInt(child.getFlexExpand())) / flex_sum;
                        fes.*.? *= @floatFromInt(remaining_space);
                    }
                }

                for (
                    slice.items(.widget),
                    slice.items(.offset),
                    flex_extra_space,
                ) |child, *offset, maybe_fes| {
                    if (maybe_fes) |fes| {
                        const child_cons = switch (self.direction) {
                            .vertical => v: {
                                const child_height = @as(u31, @intFromFloat(fes)) +
                                    child.data.size.height;

                                break :v layout.Constraints.tight(.{
                                    .width = child.data.size.width,
                                    .height = child_height,
                                });
                            },
                            .horizontal => h: {
                                const child_width = @as(u31, @intFromFloat(fes)) +
                                    child.data.size.width;

                                break :h layout.Constraints.tight(.{
                                    .width = child_width,
                                    .height = child.data.size.height,
                                });
                            },
                        };

                        try child.treevent(treev.LayoutSize{
                            .constraints = child_cons,
                            .final = true,
                        });
                    }

                    offset.* = cur_pos;
                    cur_pos += switch (self.direction) {
                        .vertical => child.data.size.height,
                        .horizontal => child.data.size.width,
                    };
                }
            }

            selfw.data.size = tv.constraints.clamp(switch (self.direction) {
                .vertical => .{
                    .width = max_orth_size,
                    .height = cur_pos,
                },
                .horizontal => .{
                    .width = cur_pos,
                    .height = max_orth_size,
                },
            });
        },
        treev.LayoutPosition => {
            const slice = self.children.slice();
            selfw.data.position = tv.position;
            for (
                slice.items(.widget),
                slice.items(.offset),
                slice.items(.pos),
            ) |child, offset, positioning| {
                const child_pos = switch (self.direction) {
                    .vertical => switch (positioning) {
                        .left => .{ .x = tv.position.x, .y = tv.position.y + offset },
                        .center => .{
                            .x = tv.position.x +
                                @divTrunc(selfw.data.size.width, 2) - @divTrunc(child.data.size.width, 2),
                            .y = tv.position.y + offset,
                        },
                        .right => .{
                            .x = tv.position.x + selfw.data.size.width - child.data.size.width,
                            .y = tv.position.y + offset,
                        },
                    },
                    .horizontal => switch (positioning) {
                        .left => .{ .x = tv.position.x + offset, .y = tv.position.y },
                        .center => .{
                            .x = tv.position.x + offset,
                            .y = tv.position.y +
                                @divTrunc(selfw.data.size.height, 2) - @divTrunc(child.data.size.height, 2),
                        },
                        .right => .{
                            .x = tv.position.x + offset,
                            .y = tv.position.y + selfw.data.size.height - child.data.size.height,
                        },
                    },
                };
                try child.treevent(treev.LayoutPosition{ .position = child_pos });
            }
        },
        treev.Draw => {
            const style: *const attreebute.BoxStyle = selfw.getAttreebute(attreebute.BoxStyle) orelse &.{};
            try style.background.drawBackground(
                tv.painter,
                .{ .pos = selfw.data.position, .size = selfw.data.size },
            );

            try tv.dispatch(selfw);
        },
        else => try tv.dispatch(selfw),
    }
}

pub fn children(self: *Box, _: *Widget) []const *Widget {
    return self.children.items(.widget);
}

pub fn addChild(self: *Box, selfw: *Widget, position: ?usize, child: *Widget) !void {
    try self.addChildPositioned(selfw, position, child, .left);
}

/// Same as the normal Widget.addChild function, except a positioning for the child is set.
pub fn addChildPositioned(
    self: *Box,
    selfw: *Widget,
    idx: ?usize,
    child: *Widget,
    positioning: ChildPositioning,
) !void {
    if (idx) |i| {
        try self.children.insert(selfw.data.allocator, i, .{ .widget = child, .pos = positioning });
    } else {
        try self.children.append(selfw.data.allocator, .{ .widget = child, .pos = positioning });
    }
}

pub fn removeChild(self: *Box, selfw: *Widget, position: ?usize) *Widget {
    _ = selfw;
    if (position) |pos| {
        const old = self.children.get(pos).widget;
        self.children.orderedRemove(pos);
        return old;
    } else {
        return self.children.pop().widget;
    }
}
