const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\..@@.@@@@.
//     \\@@@.@.@.@@
//     \\@@@@@.@.@@
//     \\@.@@@@..@.
//     \\@@.@@@@.@@
//     \\.@@@@@@@.@
//     \\.@.@.@.@@@
//     \\@.@@@.@@@@
//     \\.@@@@@@@@.
//     \\@.@.@@@.@.
// ;

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    var map = std.AutoHashMap(struct { usize, usize }, void).init(alloc);
    defer map.deinit();

    var lines = std.mem.splitAny(u8, SRC, "\n");
    var yl: usize = 0;
    while (lines.next()) |line| {
        for (std.mem.trim(u8, line, "\n"), 0..) |c, x| {
            if (c == '@') try map.put(.{ x, yl }, {});
        }
        yl += 1;
    }

    const width = std.mem.indexOf(u8, SRC, "\n").?;
    const height = yl;

    // std.debug.print("{d}x{d}\n", .{ width, height });
    // for (0..height) |y| {
    //     for (0..width) |x| {
    //         if (map.getKey(.{ x, y })) |_| std.debug.print("@", .{}) else std.debug.print(".", .{});
    //     }
    //     std.debug.print("\n", .{});
    // }
    //
    // std.debug.print("\n", .{});

    var rolls_count: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            var count: usize = 0;
            for (0..3) |ox| {
                for (0..3) |oy| {
                    if (x == 0 and ox == 0) continue;
                    if (y == 0 and oy == 0) continue;
                    if (ox == 1 and oy == 1) continue;

                    if (map.getKey(.{ x + ox - 1, y + oy - 1 })) |_| count += 1;
                }
            }
            if (count < 4) {
                if (map.getKey(.{ x, y })) |_| {
                    rolls_count += 1;
                    // std.debug.print("x", .{});
                } else {
                    // std.debug.print(".", .{});
                }
            } else {
                // if (map.getKey(.{ x, y })) |_| std.debug.print("@", .{}) else std.debug.print(".", .{});
            }
        }
        // std.debug.print("\n", .{});
    }

    std.debug.print("{d}\n", .{rolls_count});
}
