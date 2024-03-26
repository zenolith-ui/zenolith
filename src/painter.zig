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

const Chunk = @import("text/Chunk.zig");
const Color = @import("Color.zig");
const Position = @import("layout/Position.zig");
const Rectangle = @import("layout/Rectangle.zig");
const Size = @import("layout/Size.zig");
const Span = @import("text/Span.zig");
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
                .{ self, rectangle, color },
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
            line_width: u31,
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
                .{ self, rectangle, line_width, stroke_color, fill_color },
            )) |ret| try @as(anyerror!void, ret) else {
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
                .{ self, src, dest, texture },
            );
        }

        /// Draw the given span of text at the given position, where the position is the start
        /// of the span baseline. To work with the top-left corner of the span, you should
        /// use origin_off or layoutPosition() accordingly.
        /// The caller asserts that the font of the span is from the same platform as this painter.
        pub fn span(self: *Self, pos: Position, text_span: Span) !void {
            if (zenolith.debug_render) {
                for (text_span.glyphs.items) |glyph| {
                    // Size of the glyph suitable for rendering the debug overlay with.
                    const glyphsize_debug = Size{
                        .width = @max(2, glyph.glyph.size.width),
                        .height = @max(2, glyph.glyph.size.height),
                    };
                    // Position with bearing removed
                    try self.strokeRect(
                        .{
                            .pos = pos.add(glyph.position).sub(glyph.glyph.bearing),
                            .size = glyphsize_debug,
                        },
                        1,
                        Color.fromInt(0xffff00ff),
                        null,
                    );

                    // Position without bearing
                    try self.strokeRect(
                        .{
                            .pos = pos.add(glyph.position),
                            .size = glyphsize_debug,
                        },
                        1,
                        Color.fromInt(0xff0000ff),
                        null,
                    );
                }
                // Baseline
                try self.rect(
                    .{
                        .pos = pos,
                        .size = .{ .width = text_span.baseline_width, .height = 2 },
                    },
                    Color.fromInt(0x00ff00ff),
                );
            }
            return statspatch.implcall(
                self,
                .ptr,
                "span",
                anyerror!void,
                .{ self, pos, text_span },
            );
        }

        /// Draw the given chunk of text at the given position.
        /// The caller asserts that the font of the spans of this chunk is from the same platform as this painter.
        pub fn chunk(self: *Self, pos: Position, text_chunk: Chunk) !void {
            if (zenolith.debug_render) {
                for (text_chunk.spans.items) |sspan| {
                    const rendersize = sspan.span.renderSize();

                    // Size of spans suitable for debug rendering.
                    const spansize_debug = Size{
                        .width = @max(4, rendersize.width),
                        .height = @max(4, rendersize.height),
                    };

                    try self.strokeRect(
                        .{ .pos = pos.add(sspan.position), .size = spansize_debug },
                        2,
                        Color.fromInt(0xff8000ff),
                        null,
                    );
                }
            }

            if (statspatch.implcallOptional(
                self,
                .ptr,
                "chunk",
                anyerror!void,
                .{ self, pos, text_chunk },
            )) |ret| try @as(anyerror!void, ret) else {
                for (text_chunk.spans.items) |ss| {
                    try self.span(pos.add(ss.position), ss.span);
                }
            }
        }
    };
}

pub const PainterData = struct {
    /// A stack of stencils to apply to the rendered shapes. This is used to render partial widgets.
    /// The topmost stencil should be applied by the painter, if present.
    sstack: std.ArrayList(Rectangle),

    /// Create a new PainterData. Caller must call deinit.
    pub fn init(alloc: std.mem.Allocator) PainterData {
        return .{ .sstack = std.ArrayList(Rectangle).init(alloc) };
    }

    pub fn deinit(self: *PainterData) void {
        self.sstack.deinit();
    }

    /// Pushes a rectangular stencil onto the stencil stack. This would typically be called by a
    /// interested in drawing partial children in the Draw treevent handler.
    pub fn pushStencil(self: *PainterData, rect: Rectangle) !void {
        try self.sstack.append(rect);
    }

    /// Removes the topmost stencil from the stencil stack. The caller asserts that the stencil
    /// stack is not empty.
    pub fn popStencil(self: *PainterData) void {
        _ = self.sstack.pop();
    }

    /// Returns the topmost stencil of the stencil stack or null if it is empty.
    /// Painter implementations should call this when drawing shapes and perform clipping.
    pub fn peekStencil(self: PainterData) ?Rectangle {
        if (self.sstack.items.len == 0)
            return null;
        return self.sstack.items[self.sstack.items.len - 1];
    }
};

pub const Painter = statspatch.StatspatchType(Prototype, PainterData, &zenolith.painter_impls);
