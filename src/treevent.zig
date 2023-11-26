//! A treevent is an event which is propagated through the tree.
//! To fire a treevent, the treevent function is called on the respective widget.
//! This function may call a treevent's dispatch function (which must be present in all treevents!)
//! and handle a treevent accordingly. It may also choose not to call dispatch on the treevent, or
//! to conditionally dispatch it.
//!
//! Treevents are encouraged to have a fire function, taking a self parameter and a widget.
//! This function can be used by code firing a treevent and can, for example, contain code
//! to to things after the treevent has been fully dispatched or to only conditionally fire it. 
const std = @import("std");
const Widget = @import("widget.zig").Widget;

test {
    _ = Click;
    _ = Draw;
    _ = LayoutPosition;
    _ = LayoutSize;
    _ = Link;
    _ = MouseMove;
}

pub const Click = @import("treevents/Click.zig");
pub const Draw = @import("treevents/Draw.zig");
pub const LayoutPosition = @import("treevents/LayoutPosition.zig");
pub const LayoutSize = @import("treevents/LayoutSize.zig");
pub const Link = @import("treevents/Link.zig");
pub const MouseMove = @import("treevents/MouseMove.zig");

pub fn fire(widget: *Widget, tv: anytype) !void {
    const Tv = @TypeOf(tv);
    var tvv = tv;

    if (std.meta.hasFn(Tv, "preFire")) {
        try tvv.preFire();
    }
    try widget.treevent(tv);
    if (std.meta.hasFn(Tv, "postFire")) {
        try tvv.postFire();
    }
}
