const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const statspatch_dep = b.dependency("statspatch", .{ .target = target, .optimize = optimize });

    _ = b.addModule("zenolith", .{
        .root_source_file = b.path("src/main.zig"),
        .imports = &.{.{
            .name = "statspatch",
            .module = statspatch_dep.module("statspatch"),
        }},
    });

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    main_tests.root_module.addImport("statspatch", statspatch_dep.module("statspatch"));

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
