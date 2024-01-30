//! This backevent is fired on a widget to signal that this widget needs another layout pass done on it.
//! A widget should handle this if it can do another layout pass on its child while guaranteeing
//! that its own size won't change in the process.
//! If no widget is able to handle this backevent, the platform will be asked to do another layout pass.
const std = @import("std");

const Backevent = @import("../backevent.zig").Backevent;
const Widget = @import("../widget.zig").Widget;

/// Not necessarily the widget this backevent originated from, but an immediate child of the
/// widget it is currently being dispatched on. This is the child that should be laid out again.
child: *Widget,

const Relayout = @This();

pub fn prePropagate(self: *Relayout, selfb: *Backevent, next_widget: *Widget) !void {
    _ = selfb;
    self.child = next_widget;
}

pub fn unhandled(self: Relayout, selfb: Backevent, root: *Widget) !void {
    _ = selfb;

    std.debug.assert(self.child == root);

    if (root.data.platform) |plat| {
        try plat.relayoutRoot(root);
    }
}
