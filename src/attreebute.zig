/// This is a type-indexed map used for storing attreebutes
/// (inherited attributes in the widget tree).
///
/// Each widget may store an AttreebuteMap which will take precedence over it's parent's map
/// when a child widget is getting an attreebute. When resolving an attreebute, the widget tree
/// is walked toward the root node starting at the widget the attreebute is to be retrieved for,
/// checking all AttreebuteMaps until one containing the requested attreebute is found, otherwise
/// the attreebute is considered to be null.
///
/// Attreebutes which require a destructor should be avoided, and if necessary be removed manually
/// using remove prior to deinit. Due to the nature of it's implementation, the map can only call
/// destructors in remove and mod when overriding it, not in deinit.
const std = @import("std");

const util = @import("util.zig");

test {
    _ = BoxStyle;
    _ = ButtonStyle;
    _ = CurrentFont;
    _ = LabelStyle;
}

pub const BoxStyle = @import("attreebutes/BoxStyle.zig");
pub const ButtonStyle = @import("attreebutes/ButtonStyle.zig");
pub const CurrentFont = @import("attreebutes/CurrentFont.zig");
pub const LabelStyle = @import("attreebutes/LabelStyle.zig");

pub const AttreebuteMap = struct {
    const Context = struct {
        pub fn hash(self: Context, t: u64) u64 {
            _ = self;
            return t;
        }

        pub fn eql(self: Context, a: u64, b: u64) bool {
            _ = self;
            return a == b;
        }
    };

    /// An entry in the underlying map. Contains a slice to the entry's bytes as well as it's
    /// alignment to make the allocator happy when freeing with unknown type.
    const Entry = struct {
        bytes: []u8,
        log2_align: u8,

        fn of(ptr: anytype) Entry {
            return .{
                .bytes = std.mem.asBytes(ptr),
                .log2_align = std.math.log2_int(usize, @typeInfo(@TypeOf(ptr)).Pointer.alignment),
            };
        }

        fn to(self: Entry, comptime T: type) *T {
            std.debug.assert(std.math.log2_int(usize, @alignOf(T)) == self.log2_align);
            return @alignCast(std.mem.bytesAsValue(T, self.bytes[0..@sizeOf(T)]));
        }
    };

    // TODO: implement this without tricking a HashMap
    const TypeHashMap = std.HashMapUnmanaged(u64, Entry, Context, std.hash_map.default_max_load_percentage);

    /// The backing hash map. Be very careful here, if a given invariant is not held up, this will
    /// lead to invalid pointer casts!
    ///
    /// The key of this map is the type hash as returned by util.hashType and the value is a slice
    /// consisting of a pointer to the data and it's size allocated on the map's allocator.
    inner: TypeHashMap,

    /// Creates a new AttreebuteMap. Caller owns returned memory and must free it by calling deinit.
    pub fn init() AttreebuteMap {
        return .{ .inner = TypeHashMap{} };
    }

    /// Frees all resources owned by this AttreebuteMap.
    pub fn deinit(self: *AttreebuteMap, alloc: std.mem.Allocator) void {
        var iter = self.inner.valueIterator();
        while (iter.next()) |value| {
            // We need to invoke rawFree here to keep the alignment consistent.
            alloc.rawFree(
                value.bytes,
                value.log2_align,
                @returnAddress(),
            );
        }

        self.inner.deinit(alloc);
        self.* = undefined;
    }

    /// Initialize an attreebute. If the key exists, the data behind it will be freed and it's
    /// destructor will be called in accordance to util.deinitGeneric.
    /// The returned value will be a pointer to the attreebute stored in the map. It remains valid
    /// until removed or util the map is deinitialized.
    /// The returned pointer points to uninitialized memory and must be set by the caller.
    pub fn mod(self: *AttreebuteMap, alloc: std.mem.Allocator, comptime T: type) !*T {
        const valp = try alloc.create(T);
        errdefer alloc.destroy(valp);

        if (try self.inner.fetchPut(alloc, util.hashType(T), Entry.of(valp))) |old| {
            const old_val: *T = old.value.to(T);
            util.deinitGeneric(old_val, alloc);
            alloc.destroy(old_val);
        }

        return valp;
    }

    /// Retrieves the attreebute of the given type from this map, or returns null if not present.
    /// The returned pointer remains valid as long as this map, unless the attreebute is removed,
    /// in which case it is invalidated. If the attreebute is to be modified, the data behind the
    /// return value is mutable.
    ///
    /// The caller should NOT free the returned pointer!
    pub fn get(self: AttreebuteMap, comptime T: type) ?*T {
        return if (self.inner.get(util.hashType(T))) |val| val.to(T) else null;
    }

    /// If present, removes the given attreebute type from the map and returns true, otherwise
    /// returns false. The allocator is required for deinitializing the attreebute. This will call
    /// the attreebute's destructor in accordance with util.deinitGeneric.
    pub fn remove(self: *AttreebuteMap, alloc: std.mem.Allocator, comptime T: type) bool {
        if (self.inner.fetchRemove(util.hashType(T))) |old| {
            const old_val: *T = old.value.to(T);
            util.deinitGeneric(old_val, alloc);
            alloc.destroy(old_val);
            return true;
        } else {
            return false;
        }
    }

    /// Returns true if the given attreebute type is present within the map, false otherwise.
    ///
    /// If the attreebute value is required, the caller should prefer calling get
    /// and handling a null return value instead.
    pub fn has(self: AttreebuteMap, comptime T: type) bool {
        return self.inner.contains(util.hashType(T));
    }
};

test "basic type store" {
    var map = AttreebuteMap.init();
    defer map.deinit(std.testing.allocator);

    var a_state: enum { start, init, deinit } = .start;

    const A = struct {
        state: *@TypeOf(a_state),

        pub fn deinit(self: *@This()) void {
            self.state.* = .deinit;
        }
    };
    const a = try map.mod(std.testing.allocator, A);
    a.* = .{ .state = &a_state };

    map.get(A).?.state.* = .init;

    try std.testing.expect(map.has(A));
    try std.testing.expect(a.state.* == .init);
    try std.testing.expectEqual(a_state, a.state.*);

    _ = map.remove(std.testing.allocator, A);

    try std.testing.expectEqual(a_state, .deinit);

    _ = try map.mod(std.testing.allocator, u32);
}
