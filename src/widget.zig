//! The main Widget type.
//! This is based on the Statspatch library.
const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");
const layout = @import("layout.zig");
const treev = @import("treevent.zig");

const AttreebuteMap = @import("attreebute.zig").AttreebuteMap;
const Backevent = @import("backevent.zig").Backevent;
const Platform = @import("platform.zig").Platform;

test {
    _ = Box;
    _ = Button;
    _ = ChunkView;
    _ = Label;
}

pub const Box = @import("widgets/Box.zig");
pub const Button = @import("widgets/Button.zig");
pub const ChunkView = @import("widgets/ChunkView.zig");
pub const Label = @import("widgets/Label.zig");

// TODO: avoid anyerror here
fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Widget);

    return struct {
        /// Initialize a widget. This will create it's data and optionally call it's
        /// initialize funciton. The returned pointer is allocated on the given allocator.
        /// This is mostly to make the API nicer, performance overhead should be minimal.
        /// The returned pointer is freed by deinit.
        pub fn init(alloc: std.mem.Allocator, impl: anytype) !*Self {
            const self = try alloc.create(Self);
            errdefer alloc.destroy(self);
            self.* = Self.create(impl, .{
                .allocator = alloc,
                .attreebutes = null,
                .parent = null,
                .platform = null,
                .position = .{ .x = 0, .y = 0 },
                .size = .{ .width = 0, .height = 0 },
            });

            // Possibly call an initialize function. The widget can do any necessary
            // initialization of it's data here.
            _ = try (statspatch.implcallOptional(self, .ptr, "initialize", anyerror!void, .{self}) orelse {});
            return self;
        }

        /// Free the widget's resources. Will call an implementation's deinit
        /// and deinit on all children.
        pub fn deinit(self: *Self) void {
            for (self.children()) |child| {
                // TODO: call child.deinit() here
                // see: https://github.com/ziglang/zig/issues/17872
                deinit(child);
            }
            _ = statspatch.implcallOptional(self, .ptr, "deinit", void, .{self});
            if (self.data.attreebutes) |*map| map.deinit(self.data.allocator);
            self.data.allocator.destroy(self);
        }

        /// Retrieve a given attreebute. Will try this widget's map or ask it's
        /// parent if not present.
        pub fn getAttreebute(self: *Self, comptime T: type) ?*T {
            // `zig fmt` seems to be drunk here
            return (if (self.data.attreebutes) |map|
                map.get(T)
            else
                null) orelse
                if (self.data.parent) |p|
                p.getAttreebute(T)
            else
                null;
        }

        /// Called to dispatch a treevent.
        pub fn treevent(self: *Self, tv: anytype) !void {
            try statspatch.implcall(self, .ptr, "treevent", anyerror!void, .{ self, tv });
        }

        pub fn backevent(self: *Self, ev: Backevent) !void {
            try (statspatch.implcallOptional(
                self,
                .ptr,
                "backevent",
                anyerror!void,
                .{ self, ev },
            ) orelse ev.dispatch(self));
        }

        /// Returns the widget's children.
        /// The resulting slice must point to memory owned by the widget!
        pub fn children(self: *Self) []const *Self {
            return statspatch.implcallOptional(
                self,
                .ptr,
                "children",
                []const *Self,
                .{self},
            ) orelse &.{};
        }

        /// Returns the widget's flex expand factor, or 0 if it should not be expanded.
        /// Simple wrappers should delegate this to their child.
        /// Used by widgets such as Box to determine the size of their children.
        pub fn getFlexExpand(self: Self) u31 {
            return statspatch.implcallOptional(
                self,
                .self,
                "getFlexExpand",
                u31,
                .{self},
            ) orelse 0;
        }

        /// Appends a child to the end of this widget's children if position is null, otherwise
        /// it is inserted before the element at position.
        /// The caller must ensure that position is less than children().len,
        /// otherwise, undefined behaviour is invoked.
        /// Returns error.Unsupported if the widget does not support such functionality.
        pub fn addChild(self: *Self, position: ?usize, child: *Widget) !void {
            return statspatch.implcallOptional(
                self,
                .ptr,
                "addChild",
                anyerror!void,
                .{ self, position, child },
            ) orelse error.Unsupported;
        }

        /// Removes the child at position or the last child if position is null.
        /// The function then returns the removed child.
        /// The caller must ensure that position is less than children().len and children() is not
        /// empty, otherwise, undefined behaviour is invoked.
        /// Returns error.Unsupported if the widget does not support such functionality.
        pub fn removeChild(self: *Self, position: usize) !*Widget {
            return statspatch.implcallOptional(
                self,
                .ptr,
                "removeChild",
                anyerror!void,
                .{ self, position },
            ) orelse error.Unsupported;
        }
    };
}

/// Common data shared among all widgets.
pub const WidgetData = struct {
    allocator: std.mem.Allocator,
    /// A map of this widget's attreebutes.
    attreebutes: ?AttreebuteMap,
    /// The widget's parent or null if it's at the root of the widget tree.
    parent: ?*Widget,
    /// The platform the widget is running under. This is typically set by the Link treevent.
    platform: ?*Platform,
    /// The widget's position starting from the top left.
    position: layout.Position,
    /// The widget's size.
    size: layout.Size,
};

pub const Widget = statspatch.StatspatchType(Prototype, WidgetData, &zenolith.widget_impls);

test "widget" {
    var widget = try Box.init(std.testing.allocator, .vertical);
    defer widget.deinit();

    try widget.treevent(treev.Link{ .parent = null, .platform = null });
    try widget.treevent(treev.LayoutSize{
        .constraints = layout.Constraints.tight(.{ .width = 10, .height = 10 }),
        .final = true,
    });

    widget.data.attreebutes = AttreebuteMap.init();
    (try widget.data.attreebutes.?.mod(std.testing.allocator, u32)).* = 42;

    try std.testing.expectEqual(@as(u32, 42), widget.getAttreebute(u32).?.*);
}
