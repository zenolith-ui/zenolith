//! This treevent is fired first when doing a layout pass on a widget (before LayoutPosition).
//! In the handler, widgets should calculate their own size and set the size field in their data.
//! This event needs to be propagated to children so they can set their size.
const std = @import("std");

// TODO: handle error.Overflow in fire function and set flag to disable draw event for subtree.

const Constraints = @import("../layout/Constraints.zig");
const Widget = @import("../widget.zig").Widget;

/// This is set to true if this is the final layout pass being done on a widget.
/// Widgets should only propagate this to children if this is true.
///
/// This exists so that widgets that need to do multiple layout passes don't recursively layout
/// the whole sub tree on a non-final layout pass, reducing performance overhead.
///
/// Widgets should propagate this event with final = true to their children exactly once.
final: bool,

/// These represent constraints the widget laid out must adhere to.
constraints: Constraints,

const LayoutSize = @This();

/// There is no sensible default implementation for this, thus referencing the default dispatcher
/// for this treevent is always a compile error. This is one of a few treevents that are
/// mandatory to handle.
pub fn dispatch(self: LayoutSize, widget: *Widget) !void {
    _ = widget;
    _ = self;
    @compileError("Must handle LayoutSize treevent!");
}
