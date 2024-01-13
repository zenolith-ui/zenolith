//! This struct represents the freedom a Widget gets when determining its size.
//! It's passed to a Box through the LayoutSize treevent and is used to set limits to the size it can have.
const std = @import("std");

const Size = @import("Size.zig");

min: Size,
max: Size,

const Self = @This();

/// Clamps a given size to fit the Constraints
pub fn clamp(self: Self, size: Size) Size {
    return .{
        .width = std.math.clamp(size.width, self.min.width, self.max.width),
        .height = std.math.clamp(size.height, self.min.height, self.max.height),
    };
}

/// Checks if a size fits the constraints.
pub fn fits(self: Self, size: Size) bool {
    return size.width >= self.min.width and
        size.height >= self.min.height and
        size.width <= self.max.width and
        size.height <= self.max.height;
}

/// Helper for constructing a tight constraint for a given size.
pub fn tight(size: Size) Self {
    return .{
        .min = size,
        .max = size,
    };
}

/// Checks if this is a tight constraint.
pub fn isTight(self: Self) bool {
    return std.meta.eql(self.min, self.max);
}
