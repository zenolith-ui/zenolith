//! A simple button widget. This will emit an ButtonActivated backevent when clicked on.
//! This widget requries the ButtonStyle attreebute to be set!
const std = @import("std");

const attreebute = @import("../attreebute.zig");
const backevent = @import("../backevent.zig");
const treev = @import("../treevent.zig");
const layout = @import("../layout.zig");

const Color = @import("../Color.zig");
const Span = @import("../text/Span.zig");
const Widget = @import("../widget.zig").Widget;

label_str: []const u8,
span: ?Span,
hovered: bool,

const Button = @This();

pub fn init(alloc: std.mem.Allocator, label: []const u8) !*Widget {
    const self = Button{
        .label_str = label,
        .span = null,
        .hovered = false,
    };

    return try Widget.init(alloc, self);
}

pub fn deinit(self: *Button, selfw: *Widget) void {
    _ = selfw;
    if (self.span) |span| span.deinit();
}

pub fn treevent(self: *Button, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            const style = selfw.getAttreebute(attreebute.ButtonStyle) orelse
                @panic("The Button widget must have the ButtonStyle attreebute set!");
            if (self.span == null) {
                const curfont = (selfw.getAttreebute(attreebute.CurrentFont) orelse
                    @panic("The Button widget must have the CurrentFont attreebute set!")).font;
                self.span = try Span.init(selfw.data.allocator, .{
                    .font = curfont,
                    .style = style.font_style,
                    .text = self.label_str,
                });
            }

            selfw.data.size = self.span.?.renderSize().add(layout.Size.two(style.padding * 2));
        },

        treev.Draw => {
            const style = selfw.getAttreebute(attreebute.ButtonStyle) orelse
                @panic("The Button widget must have the ButtonStyle attreebute set!");
            if (self.span == null) {
                const curfont = (selfw.getAttreebute(attreebute.CurrentFont) orelse
                    @panic("The Button widget must have the CurrentFont attreebute set!")).font;
                self.span = try Span.init(selfw.data.allocator, .{
                    .font = curfont,
                    .style = style.font_style,
                    .text = self.label_str,
                });
            }

            try (if (self.hovered or selfw.data.platform.?.data.focused_widget == selfw)
                style.background_hovered
            else
                style.background).drawBackground(
                tv.painter,
                .{ .pos = selfw.data.position, .size = selfw.data.size },
            );

            try tv.painter.span(
                selfw.data.position.add(layout.Position.two(style.padding)),
                self.span.?,
            );
        },

        treev.Click => {
            if (tv.button == .left and tv.action == .click and tv.isOnWidget(selfw.*)) {
                try selfw.backevent(backevent.Backevent.create(
                    backevent.ButtonActivated{ .btn_widget = selfw },
                    {},
                ));
            }
        },

        *treev.KeyPress => {
            if (tv.action == .press and tv.scancode == .space) {
                tv.handled = true;
                try selfw.backevent(backevent.Backevent.create(
                    backevent.ButtonActivated{ .btn_widget = selfw },
                    {},
                ));
            }
        },

        treev.MouseMove => {
            self.hovered = tv.isOnWidget(selfw.*);
        },

        *treev.FocusNext => {
            tv.acquireFocus(selfw);
            try tv.dispatch(selfw);
        },

        else => try tv.dispatch(selfw),
    }
}
