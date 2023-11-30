//! Style is text theming information applied to a font. It is contained within spans.
const Color = @import("../Color.zig");

/// This is the Size of the font in pixels. Some backends (namely, TUI-based ones) may not support this.
size: usize = 24,

bold: bool = false,
italic: bool = false,
underlined: bool = false,
color: Color = Color.white(0xff),
