//! A treevent is an event which is propagated through the tree.
//! To fire a treevent, the treevent function is called on the respective widget.
//! This function may call a treevent's dispatch function (which must be present in all treevents!)
//! and handle a treevent accordingly. It may also choose not to call dispatch on the treevent, or
//! to conditionally dispatch it.
//!
//! Treevents are encouraged to have a fire function, taking a self parameter and a widget.
//! This function can be used by code firing a treevent and can, for example, contain code
//! to do things after the treevent has been fully dispatched or to only conditionally fire it.
//!
//! Treevents may have a `ptrfire` declaration of type bool. If this is set to true,
//! they will be fired as a pointer instead of by themselves. This is useful if treevents have
//! mutable state.
const std = @import("std");
const Widget = @import("widget.zig").Widget;

test {
    _ = CharType;
    _ = Click;
    _ = Draw;
    _ = FocusNext;
    _ = KeyPress;
    _ = LayoutPosition;
    _ = LayoutSize;
    _ = Link;
    _ = MouseMove;
}

pub const CharType = @import("treevents/CharType.zig");
pub const Click = @import("treevents/Click.zig");
pub const Draw = @import("treevents/Draw.zig");
pub const FocusNext = @import("treevents/FocusNext.zig");
pub const KeyPress = @import("treevents/KeyPress.zig");
pub const LayoutPosition = @import("treevents/LayoutPosition.zig");
pub const LayoutSize = @import("treevents/LayoutSize.zig");
pub const Link = @import("treevents/Link.zig");
pub const MouseMove = @import("treevents/MouseMove.zig");

/// Fires a treevent on the given widget tree.
/// This may call preFire and postFire handlers in the treevent.
pub fn fire(widget: *Widget, tv: anytype) !void {
    const Tv = switch (@typeInfo(@TypeOf(tv))) {
        .Pointer => |p| p.child,
        else => @TypeOf(tv),
    };

    const ptrfire = @hasDecl(Tv, "ptrfire") and Tv.ptrfire;
    var tvv = tv;

    // If the treevent wants to be fired by-pointer, and we've not been passed one, take one.
    const tvp = if (@typeInfo(@TypeOf(tv)) != .Pointer and ptrfire) &tvv else tvv;

    if (@hasDecl(Tv, "preFire")) {
        try tvp.preFire(widget);
    }
    try widget.treevent(tvp);
    if (@hasDecl(Tv, "postFire")) {
        try tvp.postFire(widget);
    }
}
