//! This file contains a union to be used by various widgets as a uniform way to determine how
//! their background should look. It also contains a useful function for drawing such a background.
const Color = @import("Color.zig");
const Painter = @import("painter.zig").Painter;
const Rectangle = @import("layout/Rectangle.zig");

pub const BackgroundStyle = union(enum) {
    none,
    fill: Color,
    stroked: struct { stroke: Color, fill: ?Color = null, width: usize },

    pub fn drawBackground(self: BackgroundStyle, painter: *Painter, rect: Rectangle) !void {
        switch (self) {
            .none => {},
            .fill => |col| try painter.rect(
                rect,
                col,
            ),
            .stroked => |opt| try painter.strokeRect(
                rect,
                opt.width,
                opt.stroke,
                opt.fill,
            ),
        }
    }
};
