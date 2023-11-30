//! This attreebute may be used in a widget that needs to render text to chose a font to pass to the
//! painter. A user should set this if text rendering is required.
const Font = @import("../text/font.zig").Font;

font: *Font,
