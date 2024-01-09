//! This is a iterator to iterate over the widget tree using a depth-first search algorithm.
const std = @import("std");

const Widget = @import("widget.zig").Widget;

/// The widget the iterator is currently on.
/// This is usually the widget just returned by the next function,
/// although this field should also be used for initializing the iterator,
/// in which case it is returned from next once.
w: *Widget,

/// Only true when the iterator is first initialized to return self.w instead of the next widget.
first: bool = true,

const WidgetIter = @This();

/// Returns the next widget in the tree.
pub fn next(self: *WidgetIter) ?*Widget {
    if (self.first) {
        self.first = false;
        return self.w;
    }

    var last: ?*Widget = null;
    while (true) {
        const children = self.w.children();
        const slice = if (last) |l|
            children[std.mem.indexOfScalar(*Widget, children, l).? + 1 ..]
        else
            children;
        if (slice.len == 0) {
            last = self.w;
            self.w = self.w.data.parent orelse return null;
        } else {
            self.w = slice[0];
            return slice[0];
        }
    }
}
