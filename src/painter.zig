//! The painter is a statspatch-based type which represents Zenolith's primary backend-agnostic
//! graphics abstraction. It is designed with minimalism in mind and is not supposed to provide
//! a feature-complete and flexible API, rather being designed to contain universal primitives
//! for drawing a basic GUI. For more complicated uses, backends should offer their own facilities.
//! Due to the nature of the painter as a statspatch type, it can be downcast, offering
//! access to implementation-specific APIs to widgets.
//!
//! This type intentionally doesn't work like textures do in the sense that implementations must be
//! explicitly declared, as users should be given the option of using their own custom painters,
//! for example for performing graphical modifications on subtrees.
const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");
const font = @import("font.zig");

const Color = @import("Color.zig");
const Position = @import("layout/Position.zig");
const Rectangle = @import("layout/Rectangle.zig");
const Size = @import("layout/Size.zig");
const Texture = @import("texture.zig").Texture;

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Painter);

    return struct {
        /// Draws a rectangle in the given color.
        /// The coordinates are absolute and not relative to a widget.
        /// Thus, widgets must account for their own position.
        pub fn rect(
            self: *Self,
            rectangle: Rectangle,
            color: Color,
        ) !void {
            try statspatch.implcall(
                self,
                .ptr,
                "rect",
                anyerror!void,
                .{ rectangle, color },
            );
        }

        /// Draws an outlined rectangle.
        /// line_width specifies the width of the outline. stroke_color can be used to optionall
        /// fill the rectangle in a given color.
        ///
        /// Caller asserts that
        /// rectangle.size.width >= 2 * line_width and rectangle.size.height >= 2 * line_width
        pub fn strokeRect(
            self: *Self,
            rectangle: Rectangle,
            line_width: usize,
            stroke_color: Color,
            fill_color: ?Color,
        ) !void {
            std.debug.assert(rectangle.size.width >= 2 * line_width and
                rectangle.size.height >= 2 * line_width);

            if (statspatch.implcallOptional(
                self,
                .self,
                "strokeRect",
                anyerror!void,
                .{ rectangle, line_width, stroke_color, fill_color },
            )) |ret| try ret else {
                // TODO: draw as 2 rects if fill_color is set
                const ud_size = Size{
                    .width = rectangle.size.width,
                    .height = line_width,
                };

                const lr_size = Size{
                    .width = line_width,
                    .height = rectangle.size.height,
                };

                // top
                try self.rect(.{
                    .pos = rectangle.pos,
                    .size = ud_size,
                }, stroke_color);

                // left
                try self.rect(.{
                    .pos = rectangle.pos,
                    .size = lr_size,
                }, stroke_color);

                // bottom
                try self.rect(.{
                    .pos = .{
                        .x = rectangle.pos.x,
                        .y = rectangle.pos.y + rectangle.size.height - line_width,
                    },
                    .size = ud_size,
                }, stroke_color);

                // right
                try self.rect(.{
                    .pos = .{
                        .x = rectangle.pos.x + rectangle.size.width - line_width,
                        .y = rectangle.pos.y,
                    },
                    .size = lr_size,
                }, stroke_color);

                // fill
                if (fill_color) |fc| {
                    if (rectangle.area() > 0) {
                        try self.rect(.{
                            .pos = rectangle.pos.add(Position.two(line_width)),
                            .size = rectangle.size.sub(Size.two(line_width * 2)),
                        }, fc);
                    }
                }
            }
        }

        /// Copies the region of texture identified by src to the screen at dest. If the dimensions
        /// of the two rectangles differ, the painter should stretch the texture accordingly.
        /// The caller asserts that the texture is one that has been obtained on the same platform
        /// that this painter is rendering on.
        /// The coordinates are absolute and not relative to a widget.
        /// Thus, widgets must account for their own position.
        pub fn texturedRect(
            self: *Self,
            src: Rectangle,
            dest: Rectangle,
            texture: *Texture,
        ) !void {
            return statspatch.implcall(
                self,
                .ptr,
                "texturedRect",
                anyerror!void,
                .{ src, dest, texture },
            );
        }

        /// Draw a given Chunk of laid-out text, typically obtained through the font at the given
        /// position. The caller asserts that the given chunk is compatible with this painter's
        /// underlying platform.
        pub fn text(
            self: *Self,
            pos: Position,
            chunk: font.Chunk,
            color: Color,
        ) !void {
            return statspatch.implcall(
                self,
                .ptr,
                "text",
                anyerror!void,
                .{ pos, chunk, color },
            );
        }
    };
}

pub const Painter = statspatch.StatspatchType(Prototype, void, &zenolith.painter_impls);
