//! This treevent must always be fired on a subtree after it's children have been modified.
//! It sets the parent of each widget while being propagated.

const Platform = @import("../platform.zig").Platform;
const Widget = @import("../widget.zig").Widget;

/// The parent of the widget the event is currently being handled on.
/// If this is null, the widget's parent will remain unchanged.
parent: ?*Widget,

/// The current platform. Will be applied to all widgets.
/// Unlike the parent widget, the treevent will set this to null if the value is null here.
platform: ?*Platform,

const Link = @This();

/// Dispatches the Link treevent to all children, setting their parent widget to this one.
pub fn dispatch(self: Link, widget: *Widget) !void {
    if (self.parent) |p|
        widget.data.parent = p;
    widget.data.platform = self.platform;

    for (widget.children()) |child| {
        try child.treevent(Link{ .parent = widget, .platform = self.platform });
    }
}
