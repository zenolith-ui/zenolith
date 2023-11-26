//! A 2-Dimensional position, typically used to denote where a widget is relative to the top left.
const Size = @import("Size.zig");

x: usize,
y: usize,

const Position = @This();

pub const zero = Position{ .x = 0, .y = 0 };

/// Returns a Position where both components are identical.
pub inline fn two(pos: usize) Position {
    return .{ .x = pos, .y = pos };
}

/// Performs a component-wise addition on two Positions.
pub inline fn add(self: Position, other: Position) Position {
    return .{
        .x = self.x + other.x,
        .y = self.y + other.y,
    };
}

/// Performs a component-wise addition on two Positions.
pub inline fn sub(self: Position, other: Position) Position {
    return .{
        .x = self.x - other.x,
        .y = self.y - other.y,
    };
}

/// Converts this Position to a Size.
pub inline fn size(self: Position) Size {
    return .{
        .width = self.x,
        .height = self.y,
    };
}
