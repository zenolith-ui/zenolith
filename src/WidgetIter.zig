//! This is a iterator to iterate over the widget tree
//! Depth-first
const std = @import("std");

const Widget = @import("widget.zig").Widget;

current: *Widget,

const WidgetIter = @This();

pub fn next(self: *WidgetIter) ?*Widget {
    var last: ?*Widget = null;
    while (true) {
        const children = self.current.children();
        const slice = if (last) |l|
            children[std.mem.indexOfScalar(*Widget, children, l).? + 1 ..]
        else
            children;
        if (slice.len == 0) {
            last = self.current;
            self.current = self.current.data.parent orelse return null;
        } else {
            self.current = slice[0];
            return self.current;
        }
    }
}
