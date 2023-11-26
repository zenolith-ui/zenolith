//! A backevent that is fired when a button is activated.
//! The GUI code should dispatch on the btn_widget field in this struct.
//! btn_widget will always have a Button as it's implementation.
const Widget = @import("../widget.zig").Widget;

btn_widget: *Widget,
