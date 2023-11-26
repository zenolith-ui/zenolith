//! A simple text label with a given color and size.
// TODO: use CurrentFont
// TODO: free self.chunk
const std = @import("std");

const font = @import("../font.zig");
const treev = @import("../treevent.zig");
const layout = @import("../layout.zig");

const Color = @import("../Color.zig");
const Widget = @import("../widget.zig").Widget;

font: *font.Font,
chunk: font.Chunk,
color: Color,
size: usize,

const Label = @This();

pub const LabelOptions = struct {
    alloc: std.mem.Allocator,
    font: *font.Font,
    text: []const u8,
    size: usize = 32,
    color: Color = Color.white(0xff),
};

pub const UpdateOptions = struct {
    text: []const u8,
    font: ?*font.Font = null,
    size: ?usize = null,
    color: ?Color = null,
};

pub fn init(opts: LabelOptions) !*Widget {
    const self = Label{
        .font = opts.font,
        .chunk = try opts.font.layout(opts.text, opts.size, .none),
        .color = opts.color,
        .size = opts.size,
    };
    errdefer self.chunk.deinit();

    return try Widget.init(opts.alloc, self);
}

pub fn update(self: *Label, opts: UpdateOptions) !void {
    if (opts.font) |f| self.font = f;
    if (opts.size) |s| self.size = s;
    if (opts.color) |col| self.color = col;

    const oldchunk = self.chunk;
    self.chunk = try self.font.layout(opts.text, self.size, .none);
    defer oldchunk.deinit();
}

pub fn treevent(self: *Label, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            selfw.data.size = tv.constraints.clamp(self.chunk.getSize());
        },
        treev.Draw => {
            try tv.painter.text(selfw.data.position, self.chunk, self.color);
        },
        else => try tv.dispatch(selfw),
    }
}
