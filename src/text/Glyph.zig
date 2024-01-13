//! A glyph represents the smallet possible unit of text with positioning information.
//! It is used for text layout and rendering.
const Position = @import("../layout/Position.zig");
const Size = @import("../layout/Size.zig");

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
