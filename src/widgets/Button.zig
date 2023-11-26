//! A simple button widget. This will emit an ButtonActivated backevent when clicked on.
//! This widget requries the ButtonStyle attreebute to be set!
const std = @import("std");

const attreebute = @import("../attreebute.zig");
const backevent = @import("../backevent.zig");
const font = @import("../font.zig");
const treev = @import("../treevent.zig");
const layout = @import("../layout.zig");

const Color = @import("../Color.zig");
const Widget = @import("../widget.zig").Widget;

label_str: []const u8,
chunk: ?font.Chunk,
hovered: bool,

const Button = @This();

pub fn init(alloc: std.mem.Allocator, label: []const u8) !*Widget {
    const self = Button{
        .label_str = label,
        .chunk = null,
        .hovered = false,
    };

    return try Widget.init(alloc, self);
}

pub fn deinit(self: *Button, selfw: *Widget) void {
    _ = selfw;
    if (self.chunk) |chunk|
        chunk.deinit();
}

pub fn treevent(self: *Button, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            const style = selfw.getAttreebute(attreebute.ButtonStyle) orelse
                @panic("The Button widget must have the ButtonStyle attreebute set!");
            if (self.chunk == null) {
                const curfont = (selfw.getAttreebute(attreebute.CurrentFont) orelse
                    @panic("The Button widget must have the CurrentFont attreebute set!")).font;
                self.chunk = try curfont.layout(self.label_str, style.font_size, .none);
            }

            selfw.data.size = self.chunk.?.getSize().add(layout.Size.two(style.padding * 2));
        },

        treev.Draw => {
            const style = selfw.getAttreebute(attreebute.ButtonStyle) orelse
                @panic("The Button widget must have the ButtonStyle attreebute set!");
            if (self.chunk == null) {
                const curfont = (selfw.getAttreebute(attreebute.CurrentFont) orelse
                    @panic("The Button widget must have the CurrentFont attreebute set!")).font;
                self.chunk = try curfont.layout(self.label_str, style.font_size, .none);
            }

            try (if (self.hovered) style.background_hovered else style.background).drawBackground(
                tv.painter,
                .{ .pos = selfw.data.position, .size = selfw.data.size },
            );

            try tv.painter.text(
                selfw.data.position.add(layout.Position.two(style.padding)),
                self.chunk.?,
                style.text_color,
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

        treev.MouseMove => {
            self.hovered = tv.isOnWidget(selfw.*);
        },

        else => try tv.dispatch(selfw),
    }
}
