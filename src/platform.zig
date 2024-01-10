//! The platform is the main interface to be implemnted by backends. It's responsible for driving
//! the GUI by sending treevents and rendering the GUI.
const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");

const Backevent = @import("backevent.zig").Backevent;
const Widget = @import("widget.zig").Widget;

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Platform);

    return struct {
        /// Called when a widget subtree is unlinked on this platform.
        /// Do not call this directly, instead call Widget.unlink.
        pub fn onSubtreeUnlink(self: *Self, widget: *Widget) !void {
            try (statspatch.implcallOptional(
                self,
                .ptr,
                "onSubtreeUnlink",
                anyerror!void,
                .{ self, widget },
            ) orelse {});

            if (self.data.focused_widget) |foc| {
                if (widget == foc or widget.isChildOf(foc)) {
                    self.data.focused_widget = null;
                }
            }
        }
    };
}

pub const PlatformData = struct {
    /// The widget currently being focused, or null if no widget is in focus.
    focused_widget: ?*Widget = null,
};

pub const Platform = statspatch.StatspatchType(Prototype, PlatformData, &zenolith.platform_impls);
