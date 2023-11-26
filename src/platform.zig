//! The platform is the main interface to be implemnted by backends. It's responsible for driving
//! the GUI by sending treevents, handling system events and rendering the GUI.
const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");

const Backevent = @import("backevent.zig").Backevent;

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Platform);

    return struct {
        //! Pushes a backevent to the platform's event loop.
        //! These should make their way back to the user code, how exactly depende on the Platform's
        //! API. This function must be threadsafe!
        pub fn pushBackevent(self: *Self, ev: Backevent) !void {
            try statspatch.implcall(self, .ptr, "pushBackevent", anyerror!void, .{ev});
        }
    };
}

pub const Platform = statspatch.StatspatchType(Prototype, void, &zenolith.platform_impls);
