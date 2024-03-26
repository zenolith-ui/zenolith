//! A Backevent is an event that propagates up the widget tree to be handled by widgets.
//! In case no widget handles it, it's unhandled-handler is called.
//! Custom backevents should be declared in zenolith_options.backevents as this is a statspatch type.
const std = @import("std");
const statspatch = @import("statspatch");

test {
    _ = ButtonActivated;
    _ = Relayout;
}

pub const ButtonActivated = @import("backevents/ButtonActivated.zig");
pub const Relayout = @import("backevents/Relayout.zig");

const zenolith = @import("main.zig");

const Widget = @import("widget.zig").Widget;

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Backevent);
    return struct {
        /// Called if the Backevent made it's way up the widget tree without being intercepted.
        /// The root widget will be passed.
        pub fn unhandled(self: Self, root: *Widget) !void {
            try @as(anyerror!void, statspatch.implcallOptional(
                self,
                .self,
                "unhandled",
                anyerror!void,
                .{ self, root },
            ) orelse {});
        }

        /// A callback that is automatically invoked before the backevent is propageted up the tree.
        /// Here, the backevent may make changes to itself before being passed to the parent widget.
        /// It is not invoked if there is no parent widget, that causes `unhandled` to be called immediately.
        pub fn prePropagate(self: *Self, next_widget: *Widget) !void {
            try (statspatch.implcallOptional(
                self,
                .ptr,
                "prePropagate",
                anyerror!void,
                .{ self, next_widget },
            ) orelse {});
        }

        /// Propagates this backevent up the widget tree. If the current (given) Widget has a parent,
        /// the event is propagated to it. Otherwise, the backevent's unhandled handler is called.
        /// Widgets should call this in their backevent handler if they do not wish to modify or
        /// intercept the backevent.
        pub fn dispatch(self: Self, widget: *Widget) anyerror!void {
            if (widget.data.parent) |p| {
                var selfv = self;
                try selfv.prePropagate(p);
                try p.backevent(selfv);
            } else {
                try self.unhandled(widget);
            }
        }
    };
}

pub const Backevent = statspatch.StatspatchType(Prototype, void, &zenolith.backevents);
