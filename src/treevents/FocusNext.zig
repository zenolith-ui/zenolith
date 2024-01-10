//! This treevent is fired to advance the focus to the next widget.
//! If a widget handling this treevent would like to be focused, it must call acquireFocus.
//! You may control focus by only dispatching the event to certain children.
//! The default dispatcher will propagate to all children.
//! You may only fire this event if the whole subtree as associated with a platform!
//!
//! WIDGETS THAT DO NOT CALL THE DEFAULT DISPATCHER MUST CALL checkCurrent!
// TODO: backwards focusing
const zenolith = @import("../main.zig");

const Widget = @import("../widget.zig").Widget;

/// The first widget in the tree wanting to be focused.
first_acq: ?*Widget = null,

/// True if the currently focused widget has been iterated over yet.
found_current: bool = false,

/// The last widget in the tree wanting to be focused.
/// This is only set if found_current is true!
latest_acq: ?*Widget = null,

/// The next widget in the tree wanting to be focused.
/// This is only set if found_current is true!
next_acq: ?*Widget = null,

const FocusNext = @This();

/// Call this in your treevent handler to indicate that your widget wants to be focused.
pub fn acquireFocus(self: *FocusNext, widget: *Widget) void {
    const had_current = self.found_current;
    self.checkCurrent(widget);
    self.first_acq = self.first_acq orelse widget;

    if (self.found_current) {
        self.latest_acq = widget;
    }

    if (had_current) {
        self.next_acq = self.next_acq orelse widget;
    }
}

/// If the given widget is the currently focused widget by the platform,
/// sets found_current to true.
pub fn checkCurrent(self: *FocusNext, widget: *Widget) void {
    if (!self.found_current and
        widget.data.platform.?.data.focused_widget == widget)
        self.found_current = true;
}

/// This treevent must be fired as pointer!
pub fn dispatch(self: *FocusNext, widget: *Widget) !void {
    self.checkCurrent(widget);
    for (widget.children()) |ch| {
        try ch.treevent(self);
    }
}

pub fn postFire(self: *FocusNext, widget: *Widget) !void {
    _ = widget;

    if (self.next_acq) |l| {
        l.data.platform.?.data.focused_widget = l;
        zenolith.log.debug("focus advanced to widget {s}@{x}", .{ @tagName(l.u), @intFromPtr(l) });
        return;
    }

    if (self.first_acq) |f| {
        if (self.found_current) {
            f.data.platform.?.data.focused_widget = null;
            zenolith.log.debug("focus cleared by advance", .{});
        } else {
            f.data.platform.?.data.focused_widget = f;
            zenolith.log.debug("focus started at widget {s}@{x}", .{ @tagName(f.u), @intFromPtr(f) });
        }
    }
}
