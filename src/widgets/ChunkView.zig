//! A simple widget which wraps a chunk of text.
//! The widget handles layout of the chunk but not the spans contained within it.
const std = @import("std");

const treev = @import("../treevent.zig");

const Chunk = @import("../text/Chunk.zig");
const Widget = @import("../widget.zig").Widget;

chunk: Chunk,

const ChunkView = @This();

pub fn init(alloc: std.mem.Allocator, chunk: Chunk) !*Widget {
    var self = ChunkView{ .chunk = chunk };
    self.chunk.layout(.{});
    return try Widget.init(alloc, self);
}

pub fn deinit(self: *ChunkView, selfw: *Widget) void {
    _ = selfw;
    self.chunk.deinit();
}

pub fn treevent(self: *ChunkView, selfw: *Widget, tv: anytype) !void {
    switch (@TypeOf(tv)) {
        treev.LayoutSize => {
            self.chunk.layout(.{ .wrap_width = tv.constraints.max.width });
            selfw.data.size = self.chunk.size;
        },
        treev.Draw => {
            try tv.painter.chunk(selfw.data.position, self.chunk);
        },
        else => try tv.dispatch(selfw),
    }
}
