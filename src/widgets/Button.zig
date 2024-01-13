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
            // TODO: do this in Link
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
            } else {
                self.span.?.style = style.font_style;
                self.span.?.layout();
            }

            selfw.data.size = layout.Size.two(style.padding * 2).add(.{
                .width = self.span.?.baseline_width,
                .height = self.span.?.font.yOffset(self.span.?.style.size),
            });
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
            } else {
                self.span.?.style = style.font_style;
                self.span.?.layout();
            }

            try (if (self.hovered or selfw.data.platform.?.data.focused_widget == selfw)
                style.background_hovered
            else
                style.background).drawBackground(
                tv.painter,
                .{ .pos = selfw.data.position, .size = selfw.data.size },
            );

            try tv.painter.span(
                selfw.data.position.add(layout.Position.two(style.padding)).add(.{
                    .x = 0,
                    .y = self.span.?.font.yOffset(self.span.?.style.size) - self.span.?.baseline_y,
                }),
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
            if (selfw.data.platform.?.data.focused_widget == selfw and
                !tv.handled and
                tv.action == .press and
                tv.scancode == .space)
            {
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
