//! A 2-Dimensional position, typically used to denote where a widget is relative to the top left.
const Size = @import("Size.zig");

x: i32,
y: i32,

const Position = @This();

pub const zero = two(0);

/// Returns a Position where both components are identical.
pub inline fn two(pos: i32) Position {
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
/// Caller asserts that the Position is positive.
pub inline fn size(self: Position) Size {
    return .{
        .width = @intCast(self.x),
        .height = @intCast(self.y),
    };
}
