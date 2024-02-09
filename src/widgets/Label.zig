//! A simple text label displaying given text. Font style is controlled via attreebutes.
const std = @import("std");

const font = @import("../text/font.zig");
const treev = @import("../treevent.zig");
const layout = @import("../layout.zig");

const Color = @import("../Color.zig");
const CurrentFont = @import("../attreebutes/CurrentFont.zig");
const LabelStyle = @import("../attreebutes/LabelStyle.zig");
const Span = @import("../text/Span.zig");
const Widget = @import("../widget.zig").Widget;

/// The text the Label is to be initialized with.
/// This will not change if the text is updated afterwards.
/// The reason this exists is that the widget is not linked into a tree and
/// thus has no font yet when being constructed.
initial_text: []const u8,

/// This is the inner span. Initialized upon the widget being linked.
span: ?Span,

const Label = @This();

pub fn init(alloc: std.mem.Allocator, text: []const u8) !*Widget {
    const self = Label{
        .initial_text = text,
        .span = null,
    };

    return try Widget.init(alloc, self);
}

pub fn deinit(self: *Label, selfw: *Widget) void {
    _ = selfw;
    if (self.span) |s| s.deinit();
}

pub fn treevent(self: *Label, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.Link => {
            try tv.dispatch(selfw);

            const curfont = selfw.getAttreebute(CurrentFont) orelse
                @panic("Labels require the CurrentFont attreebute!");
            self.span = try Span.init(selfw.data.allocator, .{
                .font = curfont.font,
                .text = self.initial_text,
            });
        },
        treev.LayoutSize => {
            selfw.data.size = tv.constraints.clamp(self.span.?.layoutSize());
        },
        treev.Draw => {
            const style = selfw.getAttreebute(LabelStyle) orelse
                @panic("The Button widget must have the ButtonStyle attreebute set!");

            self.span.?.style = style.font_style;
            self.span.?.layout();

            try tv.painter.span(selfw.data.position.add(self.span.?.layoutOffset()), self.span.?);
        },
        else => try tv.dispatch(selfw),
    }
}
