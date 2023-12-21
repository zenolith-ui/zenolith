//! The platform is the main interface to be implemnted by backends. It's responsible for driving
//! the GUI by sending treevents and rendering the GUI.
const std = @import("std");
const statspatch = @import("statspatch");

const zenolith = @import("main.zig");

const Backevent = @import("backevent.zig").Backevent;

fn Prototype(comptime Self: type) type {
    std.debug.assert(Self == Platform);

    return struct {};
}

pub const Platform = statspatch.StatspatchType(Prototype, void, &zenolith.platform_impls);
