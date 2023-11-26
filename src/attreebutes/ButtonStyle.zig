//! Style options for the button widget.
const BackgroundStyle = @import("../background_style.zig").BackgroundStyle;
const Color = @import("../Color.zig");

background: BackgroundStyle,

background_hovered: BackgroundStyle,

/// Spacing between the text and the button's outer bounds.
padding: usize,

/// Font size to use for the label.
font_size: usize,

text_color: Color,
