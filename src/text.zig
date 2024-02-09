const Position = @import("layout/Position.zig");
const Size = @import("layout/Size.zig");

test {
    _ = Chunk;
    _ = Font;
    _ = Span;
    _ = Style;
}

pub const Chunk = @import("text/Chunk.zig");
pub const Font = @import("text/font.zig").Font;
pub const Span = @import("text/Span.zig");
pub const Style = @import("text/Style.zig");

/// A glyph represents the smallet possible unit of text with positioning information.
/// It is used for text layout and rendering.
pub const Glyph = struct {
    /// The unicode codepoint this glyph corresponds to.
    /// This is intentionally only one codepoint. While Unicode glyphs an consist of up to 7
    /// codepoints (citation needed), these are not supported. Support might be implemented in the
    /// future, but this is currently not planned.
    codepoint: u21,

    /// The size of this glyph. This is typically the boundig box of the glyph as drawn.
    size: Size,

    /// The offset of the character's top-left corner from the baseline of the text span.
    /// When performing span layout, this is added onto the position of the cursor.
    /// This being 0/0 will thus result in the glyph being aligned below the baseline.
    /// This is typically has a negative Y offset to align the glyph above the baseline.
    bearing: Position,

    /// How much the cursor should move to the right after this glyph.
    advance: u31,
};

/// Information about the height of a font at a certain size. You may obtain this using
/// Font.heightMetrics.
pub const HeightMetrics = struct {
    /// The distance two baselines should be offset from another.
    /// This thus also represents the maximum height a glyph may have ABOVE the baseline.
    y_offset: u31,

    /// The maximum space a glyph may take up below the baseline.
    /// Note that this is space is not inserted between lines,
    /// but is instead used as padding below the last line of a chunk.
    bottom_padding: u31,

    /// Returns the total height a line will have.
    /// This is simply the sum of y_offset and bottom_padding.
    pub inline fn totalHeight(self: HeightMetrics) u31 {
        return self.y_offset + self.bottom_padding;
    }
};

