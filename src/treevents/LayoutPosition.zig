//! This treevent is fired after LayoutSize. Widgets should use this to calculate and set their
//! positions relative to the treevent's position field.
//! The dispatch function will plainly dispatch the treevent to all children keeping the position
//! the same and setting this widget's position, but this should be overriden unless the widget
//! does not have any children or is a simple wrapper and does not affect the children's position
//! in any way.
const std = @import("std");

const Position = @import("../layout/Position.zig");
const Widget = @import("../widget.zig").Widget;

position: Position,

const LayoutPosition = @This();

pub fn dispatch(self: LayoutPosition, widget: *Widget) !void {
    widget.data.position = self.position;
    for (widget.children()) |w| {
        try w.treevent(self);
    }
}
