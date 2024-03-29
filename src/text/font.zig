const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("../main.zig");

const Size = @import("../layout/Size.zig");
const Style = @import("../text/Style.zig");

fn FontPrototype(comptime Self: type) type {
    std.debug.assert(Self == Font);

    return struct {
        /// For a given font size in pixels, returns the height metrics.
        pub fn heightMetrics(self: *Self, size: u31) zenolith.text.HeightMetrics {
            return statspatch.implcall(
                self,
                .ptr,
                "heightMetrics",
                zenolith.text.HeightMetrics,
                .{size},
            );
        }

        pub fn getGlyph(self: *Self, codepoint: u21, style: Style) !zenolith.text.Glyph {
            return try statspatch.implcall(
                self,
                .ptr,
                "getGlyph",
                anyerror!zenolith.text.Glyph,
                .{ codepoint, style },
            );
        }

        /// Free resources associated with this font.
        pub fn deinit(self: *Self) void {
            statspatch.implcallOptional(self, .ptr, "deinit", void, .{}) orelse {};
        }
    };
}

pub const font_impls = impls: {
    var implementations: []const type = &.{};

    for (zenolith.platform_impls) |pi| {
        if (@hasDecl(pi, "Font")) {
            implementations = implementations ++ &[1]type{pi.Font};
        }
    }

    break :impls implementations;
};

/// The font type is a backend-specific statspatch type which encapsulates a font.
/// This is used with the painter API to draw text.
/// Platforms should specify their font implementation by declaring a Font declaration.
pub const Font = statspatch.StatspatchType(FontPrototype, void, font_impls);
