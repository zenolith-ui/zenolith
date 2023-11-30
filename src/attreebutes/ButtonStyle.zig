//! Style options for the button widget.
const BackgroundStyle = @import("../background_style.zig").BackgroundStyle;
const Color = @import("../Color.zig");
const Style = @import("../text/Style.zig");

background: BackgroundStyle,

background_hovered: BackgroundStyle,

/// Spacing between the text and the button's outer bounds.
padding: usize,

font_style: Style,
