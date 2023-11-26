//! An 8-bit RGBA color
const std = @import("std");

r: u8,
g: u8,
b: u8,
a: u8,

const Color = @This();

pub fn black(alpha: u8) Color {
    return gray(0, alpha);
}

pub fn white(alpha: u8) Color {
    return gray(0xff, alpha);
}

pub fn gray(c: u8, alpha: u8) Color {
    return .{ .r = c, .g = c, .b = c, .a = alpha };
}

pub fn toArray(self: Color) [4]u8 {
    return .{ self.r, self.g, self.b, self.a };
}

pub fn fromArray(arr: [4]u8) Color {
    return .{ .r = arr[0], .g = arr[1], .b = arr[2], .a = arr[3] };
}

pub fn toInt(self: Color) u32 {
    return @as(u32, self.r) << 24 |
        @as(u24, self.g) << 16 |
        @as(u16, self.b) << 8 |
        self.a;
}

pub fn fromInt(i: u32) Color {
    return .{
        .r = @truncate(i >> 24),
        .g = @truncate(i >> 16),
        .b = @truncate(i >> 8),
        .a = @truncate(i),
    };
}

test "integer conversion" {
    try std.testing.expectEqual(
        @as(u32, 0xf00dbabe),
        toInt(.{ .r = 0xf0, .g = 0x0d, .b = 0xba, .a = 0xbe }),
    );
    try std.testing.expectEqual(
        Color{ .r = 0xf0, .g = 0x0d, .b = 0xba, .a = 0xbe },
        fromInt(0xf00dbabe),
    );
}
