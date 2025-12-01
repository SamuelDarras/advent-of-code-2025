const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const pb1_mod = b.createModule(.{
        .root_source_file = b.path("./src/pb1.zig"),
        .target = target,
        .optimize = optimize,
    });
    const pb1_exe = b.addExecutable(.{ .name = "pb1-exe", .root_module = pb1_mod });
    b.installArtifact(pb1_exe);
    const pb1_run = b.addRunArtifact(pb1_exe);

    const pb2_mod = b.createModule(.{
        .root_source_file = b.path("./src/pb2.zig"),
        .target = target,
        .optimize = optimize,
    });
    const pb2_exe = b.addExecutable(.{ .name = "pb2-exe", .root_module = pb2_mod });
    b.installArtifact(pb2_exe);
    const pb2_run = b.addRunArtifact(pb2_exe);

    var pb1_step = b.step("pb1", "Run pb1");
    pb1_step.dependOn(&pb1_run.step);

    var pb2_step = b.step("pb2", "Run pb2");
    pb2_step.dependOn(&pb2_run.step);

    var pbs_step = b.step("pbs", "Run pb1 and pb2");
    pbs_step.dependOn(pb1_step);
    pbs_step.dependOn(pb2_step);
}
