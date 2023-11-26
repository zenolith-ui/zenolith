//! This data structure is a statspatch type allowing interfacing between zenolith and a platform's
//! rendering system for drawing textures.
//! Unlike other statspatch types in Zenolith, there is no root option for declaring implementations.
//! Instead, declared platform implementations should have a declaration called Texture containing
//! their texture implementation type.
const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");

const Size = @import("layout/Size.zig");

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Texture);

    return struct {
        /// Gets this textures size in pixels.
        pub fn getSize(self: Self) Size {
            return statspatch.implcall(self, .self, "getSize", Size, .{});
        }
    };
}

pub const impls = impls: {
    var implementations: []const type = &.{};

    for (zenolith.platform_impls) |pi| {
        if (@hasDecl(pi, "Texture")) {
            implementations = implementations ++ &[1]type{pi.Texture};
        }
    }

    break :impls implementations;
};

pub const Texture = statspatch.StatspatchType(Prototype, void, impls);
