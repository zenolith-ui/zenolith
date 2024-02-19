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
pub inline fn area(self: Rectangle) u31 {
    return self.size.area();
}

pub inline fn contains(self: Rectangle, pos: Position) bool {
    return pos.x >= self.pos.x and
        pos.y >= self.pos.y and
        pos.x <= self.pos.x + self.size.width and
        pos.y <= self.pos.y + self.size.height;
}

pub fn intersection(self: Rectangle, other: Rectangle) ?Rectangle {
    const pos1 = Position{
        .x = @max(self.pos.x, other.pos.x),
        .y = @max(self.pos.y, other.pos.y),
    };

    const pos2 = Position{
        .x = @min(self.pos.x + self.size.width, other.pos.x + other.size.width),
        .y = @min(self.pos.y + self.size.height, other.pos.y + other.size.height),
    };

    if (pos1.x < pos2.x and pos1.y < pos2.y) {
        return .{
            .pos = pos1,
            .size = pos2.sub(pos1).size(),
        };
    }
    return null;
}
