const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\.......S.......
//     \\...............
//     \\.......^.......
//     \\...............
//     \\......^.^......
//     \\...............
//     \\.....^.^.^.....
//     \\...............
//     \\....^.^...^....
//     \\...............
//     \\...^.^...^.^...
//     \\...............
//     \\..^...^.....^..
//     \\...............
//     \\.^.^.^.^.^...^.
//     \\...............
// ;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();

    var set = std.AutoHashMap(usize, void).init(alloc);
    defer set.deinit();

    var next_set = std.AutoHashMap(usize, void).init(alloc);
    defer next_set.deinit();

    var lines_it = std.mem.splitAny(u8, SRC, "\n");
    const first_line = lines_it.next().?;

    for (first_line, 0..) |c, i| {
        if (c == 'S') {
            try set.put(i, {});
            break;
        }
    }

    var count: usize = 0;
    while (lines_it.next()) |line| {
        if (line.len <= 0) break;

        var key_it = set.keyIterator();
        while (key_it.next()) |k| {
            const c = line[k.*];
            if (c == '^') {
                try next_set.put(k.* - 1, {});
                try next_set.put(k.* + 1, {});
                count += 1;
            } else {
                try next_set.put(k.*, {});
            }
        }
        set = try next_set.clone();
        next_set.clearRetainingCapacity();

        // for (0..line.len) |i| {
        //     if (set.get(i)) |_| {
        //         std.debug.print("|", .{});
        //     } else {
        //         std.debug.print(".", .{});
        //     }
        // }
        // std.debug.print("\n", .{});
    }

    std.debug.print("{d}\n", .{count});
}
