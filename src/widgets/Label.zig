//! A simple text label with a given color and size.
// TODO: use CurrentFont
const std = @import("std");

const font = @import("../text/font.zig");
const treev = @import("../treevent.zig");
const layout = @import("../layout.zig");

const Color = @import("../Color.zig");
const Span = @import("../text/Span.zig");
const Widget = @import("../widget.zig").Widget;

font: *font.Font,
span: Span,

const Label = @This();

pub fn init(alloc: std.mem.Allocator, opts: Span.InitOptions) !*Widget {
    const self = Label{
        .font = opts.font,
        .span = try Span.init(alloc, opts),
    };
    errdefer self.span.deinit();

    return try Widget.init(alloc, self);
}

pub fn deinit(self: *Label, selfw: *Widget) void {
    _ = selfw;
    self.span.deinit();
}

pub fn treevent(self: *Label, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            selfw.data.size = tv.constraints.clamp(.{
                .width = self.span.baseline_width,
                .height = self.span.font.yOffset(self.span.style.size),
            });
        },
        treev.Draw => {
            try tv.painter.span(selfw.data.position.add(.{
                .x = 0,
                .y = self.span.font.yOffset(self.span.style.size) - self.span.baseline_y,
            }), self.span);
        },
        else => try tv.dispatch(selfw),
    }
}
