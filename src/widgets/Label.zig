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
    errdefer self.span.deinit(alloc);

    return try Widget.init(alloc, self);
}

pub fn deinit(self: *Label, selfw: *Widget) void {
    self.span.deinit(selfw.data.allocator);
}

pub fn treevent(self: *Label, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            selfw.data.size = tv.constraints.clamp(self.span.renderSize());
        },
        treev.Draw => {
            try tv.painter.span(selfw.data.position, self.span);
        },
        else => try tv.dispatch(selfw),
    }
}
