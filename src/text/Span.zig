//! A span is a one-line piece of text. It consists of glyphs and performs single-line layout on them.
//! It also has information on the font, style, color as well as bounding boxes.
const std = @import("std");

const Font = @import("font.zig").Font;
const Glyph = @import("Glyph.zig");
const Position = @import("../layout/Position.zig");
const Size = @import("../layout/Size.zig");
const Style = @import("Style.zig");

glyphs: std.MultiArrayList(PositionedGlyph) = .{},
font: *Font,
style: Style,

/// The Y-coordinate of the baseline of this span relative to it's top.
/// The chunker uses this for aligning spans.
baseline_y: usize = 0,

const Span = @This();

pub const PositionedGlyph = struct {
    glyph: Glyph,
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
        .font = opts.font,
        .style = opts.style,
    };

    try self.updateGlyphs(alloc, .{ .text = opts.text });
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
    alloc: std.mem.Allocator,
    opts: UpdateGlyphsOptions,
) !void {
    if (opts.style) |style| self.style = style;
    if (opts.font) |font| self.font = font;

    self.glyphs.shrinkRetainingCapacity(0);

    var iter = std.unicode.Utf8Iterator{ .i = 0, .bytes = opts.text };
    while (iter.nextCodepoint()) |codepoint| {
        try self.glyphs.append(alloc, .{
            .glyph = try self.font.getGlyph(codepoint, self.style),
            .position = Position.zero,
        });
    }
}

/// Positions the glyphs of the span and sets baseline_y.
pub fn layout(self: *Span) void {
    const glyphslice = self.glyphs.slice();

    // We start at the middle of the "coordinate system" here to leave as much space as possible
    // in all directions. This is later compensated for.
    var cursor = Position{
        .x = std.math.maxInt(usize) / 2,
        .y = std.math.maxInt(usize) / 2,
    };

    // Minimum position coordinate of the glyphs.
    var min_pos = Position{
        .x = std.math.maxInt(usize),
        .y = std.math.maxInt(usize),
    };

    for (glyphslice.items(.glyph), glyphslice.items(.position)) |glyph, *position| {
        position.* = cursor.offset(glyph.bearing);

        if (position.x < min_pos.x) min_pos.x = position.x;
        if (position.y < min_pos.y) min_pos.y = position.y;

        cursor.x += glyph.advance;
    }

    for (glyphslice.items(.position)) |*pos| {
        pos.* = pos.sub(min_pos);
    }

    self.baseline_y = cursor.y - min_pos.y;
}

/// Free owned data. Caller must provide the same allocator as to init!
pub fn deinit(self_: Span, alloc: std.mem.Allocator) void {
    var self = self_;
    self.glyphs.deinit(alloc);
}

/// This determines the size of the span as rendered. This fully contains the glyphs.
pub fn renderSize(self: Span) Size {
    var size = Size.zero;

    const glyphslice = self.glyphs.slice();

    for (glyphslice.items(.glyph), glyphslice.items(.position)) |glyph, pos| {
        const xmax = glyph.size.width + pos.x;
        const ymax = glyph.size.height + pos.y;

        if (xmax > size.width) size.width = xmax;
        if (ymax > size.height) size.height = ymax;
    }

    return size;
}
