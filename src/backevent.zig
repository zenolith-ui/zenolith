//! A Backevent is an event that propagates up the widget tree to be handled by widgets.
//! In case no widget handles it, it's unhandled-handler is called.
//! Custom backevents should be declared in zenolith_options.backevents as this is a statspatch type.
const std = @import("std");
const statspatch = @import("statspatch");

test {
    _ = ButtonActivated;
}

pub const ButtonActivated = @import("backevents/ButtonActivated.zig");

const zenolith = @import("main.zig");

const Widget = @import("widget.zig").Widget;

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Backevent);
    return struct {
        /// Called if the Backevent made it's way up the widget tree without being intercepted.
        /// The root widget will be passed.
        pub fn unhandled(self: Self, root: *Widget) !void {
            try (statspatch.implcallOptional(
                self,
                .self,
                "unhandled",
                anyerror!void,
                .{ self, root },
            ) orelse {});
        }

        /// Propagates this backevent up the widget tree. If the current (given) Widget has a parent,
        /// the event is propagated to it. Otherwise, the backevent's unhandled handler is called.
        /// Widgets should call this in their backevent handler if they do not wish to modify or
        /// intercept the backevent.
        pub fn dispatch(self: Self, widget: *Widget) anyerror!void {
            if (widget.data.parent) |p| {
                try p.backevent(self);
            } else {
                try self.unhandled(widget);
            }
        }
    };
}

pub const Backevent = statspatch.StatspatchType(Prototype, void, &zenolith.backevents);
