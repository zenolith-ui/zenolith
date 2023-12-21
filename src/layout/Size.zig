//! A size, usually used for widget sizes.
const Position = @import("Position.zig");

width: u31,
height: u31,

const Size = @This();

pub const zero = Size{ .width = 0, .height = 0 };

/// Returns a Size where both components are identical.
pub inline fn two(size: u31) Size {
    return .{ .width = size, .height = size };
}

/// Returns the area of this size.
pub inline fn area(self: Size) u31 {
    return self.width * self.height;
}

/// Performs a component-wise addition on two Sizes.
pub inline fn add(self: Size, other: Size) Size {
    return .{
        .width = self.width + other.width,
        .height = self.height + other.height,
    };
}

/// Performs a component-wise addition on two Sizes.
pub inline fn sub(self: Size, other: Size) Size {
    return .{
        .width = self.width - other.width,
        .height = self.height - other.height,
    };
}

/// Converts this Size to a Position.
pub inline fn position(self: Size) Position {
    return .{ .x = self.width, .y = self.height };
}
