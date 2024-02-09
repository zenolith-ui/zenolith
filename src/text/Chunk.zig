//! A chunk is a collection of multiple spans, laid out in a multi-line fashion.
//! It may do wrapping on span boundaries depending on the wrap_mode.
//! You may access the spans field to modify children, but layout must be called again afterwards.
const std = @import("std");
const zenolith = @import("../main.zig");

const Position = @import("../layout/Position.zig");
const Size = @import("../layout/Size.zig");
const Span = @import("Span.zig");

spans: std.ArrayList(Subspan),

/// The size of the chunk calculated from font info.
/// This is not necessarily the size of chunk as rendered.
size: Size,

const Chunk = @This();

/// How to wrap a subspan in this chunk.
pub const WrapMode = enum {
    /// Wrap this span to the next line if it won't fit on the current line.
    auto,

    /// Always wrap this span to the next line.
    always,

    /// Never wrap the span.
    never,
};

/// A subspan of a chunk. This contains the span as well as it's position within the chunk and
/// the wrap mode.
pub const Subspan = struct {
    /// Underlying span
    span: Span,
    /// How to wrap *this* subspan, not the next one.
    wrap_mode: WrapMode = .auto,
    /// Relative to the chunk.
    position: Position = Position.zero,
};

/// Creates a new, empty chunk. Caller must call deinit when done.
/// You should add spans by accessing the spans field.
pub fn init(alloc: std.mem.Allocator) Chunk {
    return .{
        .spans = std.ArrayList(Subspan).init(alloc),
        .size = Size.zero,
    };
}

pub fn deinit(self: Chunk) void {
    for (self.spans.items) |ss| {
        ss.span.deinit();
    }
    self.spans.deinit();
}

pub const LayoutOptions = struct {
    /// This controls the width after which the chunk should wrap spans.
    /// Note that this does not guarantee that chunk's width will be within wrap_width,
    /// as spans may have their wrap_mode set to .never or not fit within the wrap_width.
    /// 0 means no wrapping.
    wrap_width: u31 = 0,

    /// Also layout spans first.
    layout_spans: bool = false,
};

/// Perform layout on this chunk's spans.
pub fn layout(self: *Chunk, opts: LayoutOptions) void {
    if (self.spans.items.len == 0) {
        self.size = Size.zero;
        return;
    }

    if (opts.layout_spans) {
        for (self.spans.items) |*ss| {
            ss.span.layout();
        }
    }

    self.size = Size.zero;

    // The cursor points to X coordinate of the current glyph and the Y coordinate of the
    // PREVIOUS baseline (or 0).
    var cursor = Position{
        // Handle glyphs with negative x-bearing at the beginning of new lines.
        .x = -self.spans.items[0].span.origin_off.x,
        // We move down all spans by the line height after each line.
        .y = 0,
    };

    // The index of the first span of the current line.
    var line_start_idx: usize = 0;

    for (self.spans.items, 0..) |*span, i| {
        const should_wrap = switch (span.wrap_mode) {
            .never => false,
            .always => true,
            .auto => auto: {
                if (opts.wrap_width == 0) break :auto false;

                // The distance to the next point where a wrap might occur from the end of this span's baseline.
                // For spans with wrap_mode != .never, this is the distance to the end of this span,
                // otherwise it is either the distance to the next span to satisfy this criterium
                // or the length of all remaining spans after this one.
                var width: i32 = 0;
                for (self.spans.items[i..]) |lspan| {
                    width += lspan.span.baseline_width;
                    if (lspan.wrap_mode != .never) break;
                }

                break :auto cursor.x + width > opts.wrap_width;
            },
        };

        if (should_wrap) {
            cursor.y += self.offsetLineByHeight(line_start_idx, i).y_offset;
            line_start_idx = i;
            if (cursor.x > self.size.width) self.size.width = @intCast(cursor.x);
            cursor.x = -span.span.origin_off.x;
        }

        span.position = .{
            .x = cursor.x,
            .y = cursor.y,
        };

        cursor.x += span.span.baseline_width;
    }
    const last_metrics = self.offsetLineByHeight(line_start_idx, self.spans.items.len);
    cursor.y += last_metrics.y_offset;

    self.size.height = @intCast(cursor.y + last_metrics.bottom_padding);
    if (cursor.x > self.size.width) self.size.width = @intCast(cursor.x);
}

/// Offsets all chunks in the given range downwards by their line y_offset and returns that line's
/// height metrics..
fn offsetLineByHeight(self: *const Chunk, start_idx: usize, end_idx: usize) zenolith.text.HeightMetrics {
    var max = zenolith.text.HeightMetrics{
        .y_offset = 0,
        .bottom_padding = 0,
    };

    for (self.spans.items[start_idx..end_idx]) |span| {
        const metrics = span.span.font.heightMetrics(span.span.style.size);
        max = .{
            .y_offset = @max(max.y_offset, metrics.y_offset),
            .bottom_padding = @max(max.bottom_padding, metrics.bottom_padding),
        };
    }

    for (self.spans.items[start_idx..end_idx]) |*span| {
        span.position.y += max.y_offset;
    }

    return max;
}
