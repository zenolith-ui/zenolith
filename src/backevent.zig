//! A Backevent is an event that is headed to the event loop to be handled by the user code. Such an
//! event is either pushed straight to the platform event loop using Platform.pushBackevent or
//! handled by widgets, travelling up the widget tree, where widgets can intercept them or
//! propagate them using the dispatch function. Custom backevents should be declared
//! in zenolith_options.backevents as this is a statspatch type.
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
        //! Propagates this backevent up the widget tree. If the current (given) Widget has a parent,
        //! the event is propagated to it. Otherwise, it is pushed to the platform event loop.
        //! Widgets should call this in their backevent handler if they do not wish to modify or
        //! intercept the backevent.
        pub fn dispatch(self: Self, widget: *Widget) anyerror!void {
            if (widget.data.parent) |p| {
                try p.backevent(self);
            } else {
                try widget.data.platform.?.pushBackevent(self);
            }
        }
    };
}

pub const Backevent = statspatch.StatspatchType(Prototype, void, &zenolith.backevents);
