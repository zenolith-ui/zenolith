test {
    _ = Font;
    _ = Glyph;
    _ = Span;
    _ = Style;
}

pub const Font = @import("text/font.zig").Font;
pub const Glyph = @import("text/Glyph.zig");
pub const Span = @import("text/Span.zig");
pub const Style = @import("text/Style.zig");
