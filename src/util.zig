//! This module contains general-purpose utilities.
const std = @import("std");

/// A generic deinit function which should do a decent job at deinitializing any given type.
/// If you want your type to be picked up here, you must provide an accessible `deinit` function,
/// taking a `self` parameter and optionally an allocator as a second parameter.
pub fn deinitGeneric(x: anytype, alloc: std.mem.Allocator) void {
    const BaseT = @TypeOf(x);
    const T = switch (@typeInfo(BaseT)) {
        .Pointer => |pointer_info| pointer_info.child,
        else => BaseT,
    };

    switch (@typeInfo(T)) {
        .Struct, .Enum, .Union, .Opaque => {},
        else => return, // type cannot have functions
    }

    if (@hasDecl(T, "deinit") and @typeInfo(@TypeOf(T.deinit)) == .Fn) {
        const params = @typeInfo(@TypeOf(T.deinit)).Fn.params;

        if (params.len == 1) {
            x.deinit();
        } else if (params.len == 2 and params[1].type == std.mem.Allocator) {
            x.deinit(alloc);
        }
    }
}

/// Computes a hash for a given type. This is guaranteed to be unique per-type given (at least
/// that's what this is supposed to do, further testing required).
pub fn hashType(comptime T: type) u64 {
    return comptime std.hash_map.hashString(@typeName(T));
}

test "deinitGeneric" {
    var type_with_plain_deinit = std.ArrayList(u64).init(std.testing.allocator);

    // ensure we get a memory leak if deinitGeneric doesn't work
    try type_with_plain_deinit.append(0xdeadbeef);

    // alloc shouldn't be used here
    deinitGeneric(&type_with_plain_deinit, std.testing.failing_allocator);

    var type_with_alloc_deinit = std.ArrayListUnmanaged(u64){};

    try type_with_alloc_deinit.append(std.testing.allocator, 0xb00b135);

    deinitGeneric(&type_with_alloc_deinit, std.testing.allocator);
}

test "hashType" {
    const A = struct {};
    const B = A;

    try std.testing.expectEqual(hashType(A), hashType(B));
}
