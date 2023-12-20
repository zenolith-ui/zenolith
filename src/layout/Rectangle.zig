//! A simple type describing a rectangle in the GUI. The position is relative to the top left.
const Position = @import("Position.zig");
const Size = @import("Size.zig");

pos: Position,
size: Size,

const Rectangle = @This();

pub const zero = Rectangle{
    .pos = Position.zero,
    .size = Size.zero,
};

/// Returns the area of this Rectangle.
pub inline fn area(self: Rectangle) usize {
    return self.size.area();
}

pub inline fn contains(self: Rectangle, pos: Position) bool {
    return pos.x >= self.pos.x and
        pos.y >= self.pos.y and
        pos.x <= self.pos.x + @as(isize, @intCast(self.size.width)) and
        pos.y <= self.pos.y + @as(isize, @intCast(self.size.height));
}
