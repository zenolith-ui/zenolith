//! A structure containing all theme-related values of zenolith's builtin widgets.
//! This allows for convenient handling of themes for default widgets.
const std = @import("std");

const AttreebuteMap = @import("attreebute.zig").AttreebuteMap;
const BoxStyle = @import("attreebutes/BoxStyle.zig");
const ButtonStyle = @import("attreebutes/ButtonStyle.zig");
const Color = @import("Color.zig");
const LabelStyle = @import("attreebutes/LabelStyle.zig");

pub const catppuccin_latte = Theme{
    .box = .{ .background = .{ .fill = Color.fromInt(0xeff1f5ff) } },
    .button = .{
        .background = .{ .stroked = .{
            .stroke = Color.fromInt(0xe64553ff),
            .fill = Color.fromInt(0xccd0daff),
            .width = 4,
        } },
        .background_hovered = .{ .stroked = .{
            .stroke = Color.fromInt(0xe64553ff),
            .fill = Color.fromInt(0xbcc0ccff),
            .width = 2,
        } },
        .padding = 4,
        .font_style = .{ .color = Color.fromInt(0x4c4f69ff) },
    },
    .label = .{ .font_style = .{ .color = Color.fromInt(0x4c4f69ff) } },
};

pub const catppuccin_frappe = Theme{
    .box = .{ .background = .{ .fill = Color.fromInt(0x303446ff) } },
    .button = .{
        .background = .{ .stroked = .{
            .stroke = Color.fromInt(0xea999cff),
            .fill = Color.fromInt(0x414559ff),
            .width = 4,
        } },
        .background_hovered = .{ .stroked = .{
            .stroke = Color.fromInt(0xea999cff),
            .fill = Color.fromInt(0x51576dff),
            .width = 2,
        } },
        .padding = 4,
        .font_style = .{ .color = Color.fromInt(0xc6d0f5ff) },
    },
    .label = .{ .font_style = .{ .color = Color.fromInt(0xc6d0f5ff) } },
};

pub const catppuccin_macchiato = Theme{
    .box = .{ .background = .{ .fill = Color.fromInt(0x24273aff) } },
    .button = .{
        .background = .{ .stroked = .{
            .stroke = Color.fromInt(0xee99a0ff),
            .fill = Color.fromInt(0x363a4fff),
            .width = 4,
        } },
        .background_hovered = .{ .stroked = .{
            .stroke = Color.fromInt(0xee99a0ff),
            .fill = Color.fromInt(0x09494d64ff),
            .width = 2,
        } },
        .padding = 4,
        .font_style = .{ .color = Color.fromInt(0xcad3f5ff) },
    },
    .label = .{ .font_style = .{ .color = Color.fromInt(0xcad3f5ff) } },
};

pub const catppuccin_mocha = Theme{
    .box = .{ .background = .{ .fill = Color.fromInt(0x1e1e2eff) } },
    .button = .{
        .background = .{ .stroked = .{
            .stroke = Color.fromInt(0xeba0acff),
            .fill = Color.fromInt(0x313244ff),
            .width = 4,
        } },
        .background_hovered = .{ .stroked = .{
            .stroke = Color.fromInt(0xeba0acff),
            .fill = Color.fromInt(0x45475aff),
            .width = 2,
        } },
        .padding = 4,
        .font_style = .{ .color = Color.fromInt(0xcdd6f4ff) },
    },
    .label = .{ .font_style = .{ .color = Color.fromInt(0xcdd6f4ff) } },
};

box: BoxStyle,
button: ButtonStyle,
label: LabelStyle,

const Theme = @This();

pub fn apply(self: Theme, alloc: std.mem.Allocator, map: *AttreebuteMap) !void {
    (try map.mod(alloc, BoxStyle)).* = self.box;
    (try map.mod(alloc, ButtonStyle)).* = self.button;
    (try map.mod(alloc, LabelStyle)).* = self.label;
}
