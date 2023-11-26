const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");

const Size = @import("layout/Size.zig");

fn FontPrototype(comptime Self: type) type {
    std.debug.assert(Self == Font);

    return struct {
        /// Performs layout on the given string of UTF-8 encoded text.
        /// The wrap parameter controls how text should be wrapped. If set to none, no text wrapping
        /// should be done, if set to word or glyph it should wrap whole words or whole glyphs
        /// respectively. The size parameter is in px. Platforms where this isn't applicable
        /// should try to make the font size match closely.
        pub fn layout(
            self: *Self,
            text: []const u8,
            size: usize,
            wrap: TextWrap,
        ) !Chunk {
            return try statspatch.implcall(
                self,
                .ptr,
                "layout",
                anyerror!Chunk,
                .{ text, size, wrap },
            );
        }

        /// Free resources associated with this font.
        pub fn deinit(self: Self) void {
            statspatch.implcallOptional(self, .self, "deinit", void, .{}) orelse {};
        }
    };
}

fn ChunkPrototype(comptime Self: type) type {
    std.debug.assert(Self == Chunk);

    return struct {
        /// Returns the total size of the chunk.
        /// This is often used for layout to determine the size of text.
        pub fn getSize(self: Self) Size {
            return statspatch.implcall(self, .self, "getSize", Size, .{});
        }

        /// Free resources associated with this chunk.
        pub fn deinit(self: Self) void {
            return statspatch.implcallOptional(self, .self, "deinit", void, .{}) orelse {};
        }
    };
}

/// Determines how text should be wrapped when doing text layout.
pub const TextWrap = union(enum) {
    /// Don't wrap text.
    none,
    /// Wrap words after the given maximum width.
    word: usize,
    /// Wrap individual glyphs after the given maximum width.
    glyph: usize,
};

pub const font_impls = impls: {
    var implementations: []const type = &.{};

    for (zenolith.platform_impls) |pi| {
        if (@hasDecl(pi, "Font")) {
            implementations = implementations ++ &[1]type{pi.Font};
        }
    }

    break :impls implementations;
};

pub const chunk_impls = impls: {
    var implementations: [font_impls.len]type = undefined;
    for (&implementations, font_impls) |*chunk, font| {
        chunk.* = font.Chunk;
    }

    break :impls &implementations;
};

/// The font type is a backend-specific statspatch type which encapsulates a font.
/// This is used with the painter API to draw text.
/// Platforms should specify their font implementation by declaring a Font declaration.
pub const Font = statspatch.StatspatchType(FontPrototype, void, font_impls);

/// A chunk represents a laid-out piece of text. This is created by the font using the layout
/// function. It typically contains information about the positions of individual glyphs, although
/// this is up to the backend.
/// Fonts should specify their chunk implementation by declaring a Chunk declaration.
pub const Chunk = statspatch.StatspatchType(ChunkPrototype, void, chunk_impls);
