//! A span is a one-line piece of text. It consists of glyphs and performs single-line layout on them.
//! It also has information on the font, style, color as well as bounding boxes.
const std = @import("std");
const zenolith = @import("../main.zig");

const Font = @import("font.zig").Font;
const Position = @import("../layout/Position.zig");
const Size = @import("../layout/Size.zig");
const Style = @import("Style.zig");

glyphs: std.ArrayList(PositionedGlyph),
font: *Font,
style: Style,

/// This represents an offset from relative 0/0 to the start of the baseline.
/// This means that the y component is the height of the highest glyph (minus the below-baseline part).
/// The x component is a horizontal offset the first glyph may have. This is commonly the case with
/// letters such as 'j' where the hook would be a little to the left of where the text should be aligned.
origin_off: Position = Position.zero,

/// The width of the baseline. This is calculated as the distance the cursor moved during layout.
/// This does not always correspond to renderSize().width due to padding between glyphs.
baseline_width: u31 = 0,

const Span = @This();

pub const PositionedGlyph = struct {
    glyph: zenolith.text.Glyph,
    position: Position,
};

pub const InitOptions = struct {
    font: *Font,
    style: Style = .{},
    text: []const u8,
};

/// Initializes this span with some text. This performs layout.
/// The caller must call deinit when done to free memory.
pub fn init(alloc: std.mem.Allocator, opts: InitOptions) !Span {
    var self = Span{
        .glyphs = std.ArrayList(PositionedGlyph).init(alloc),
        .font = opts.font,
        .style = opts.style,
    };

    try self.updateGlyphs(.{ .text = opts.text });
    self.layout();

    return self;
}

pub const UpdateGlyphsOptions = struct {
    font: ?*Font = null,
    style: ?Style = null,
    text: []const u8,
};

/// Update the glyphs in this span to those of the given string.
/// Note that this does not recalculate positions! The caller must assure that `layout` is called
/// after this.
pub fn updateGlyphs(
    self: *Span,
    opts: UpdateGlyphsOptions,
) !void {
    if (opts.style) |style| self.style = style;
    if (opts.font) |font| self.font = font;

    self.glyphs.clearRetainingCapacity();

    var iter = std.unicode.Utf8Iterator{ .i = 0, .bytes = opts.text };
    while (iter.nextCodepoint()) |codepoint| {
        try self.glyphs.append(.{
            .glyph = try self.font.getGlyph(codepoint, self.style),
            .position = Position.zero,
        });
    }
}

/// Positions the glyphs of the span and sets origin_off.
pub fn layout(self: *Span) void {
    var cursor = Position.zero;
    var min_y: i32 = 0;

    for (self.glyphs.items) |*pglyph| {
        pglyph.position = cursor.add(pglyph.glyph.bearing);

        min_y = @min(min_y, pglyph.glyph.bearing.y);

        cursor.x += pglyph.glyph.advance;
    }

    self.origin_off = .{
        .x = if (self.glyphs.items.len > 0) self.glyphs.items[0].position.x else 0,
        .y = -min_y,
    };

    self.baseline_width = @intCast(cursor.x);
}

/// Free owned data.
pub fn deinit(self: Span) void {
    self.glyphs.deinit();
}

/// This determines the size of the span as rendered. This fully contains the glyphs.
/// The given size is to be treated as relative to the span's origin, with origin_off calculated in.
pub fn renderSize(self: Span) Size {
    if (self.glyphs.items.len == 0) return Size.zero;

    var max = Position.two(std.math.minInt(i32));

    for (self.glyphs.items) |glyph| {
        max.y = @max(max.y, glyph.position.y + glyph.glyph.size.height);
        max.x = @max(max.x, glyph.position.x + glyph.glyph.size.width);
    }

    return max.size();
}

/// The size to be used when this span is laid out stand-alone. It will always fully contain all
/// glayphs, but unlike render size, it will include padding as required by the font.
/// Use this if you want to include spans in widgets.
pub fn layoutSize(self: Span) Size {
    return .{
        .width = @intCast(@as(i32, self.baseline_width) + self.origin_off.x),
        .height = self.font.heightMetrics(self.style.size).totalHeight(),
    };
}

/// This is similar to self.origin_off, with the difference that the the baseline won't be
/// positioned in accordance with the largest glyph but instead using the font height metrics.
/// This is typically preferred, but may overly complex in some situations.
pub fn layoutOffset(self: Span) Position {
    return .{
        .x = self.origin_off.x,
        .y = self.font.heightMetrics(self.style.size).y_offset,
    };
}
