const std = @import("std");

const SRC = @embedFile("./src2.txt");
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

const Key = usize;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();

    var set = std.AutoHashMap(Key, usize).init(alloc);
    defer set.deinit();

    var next_set = std.AutoHashMap(Key, usize).init(alloc);
    defer next_set.deinit();

    var lines_it = std.mem.splitAny(u8, SRC, "\n");
    const first_line = lines_it.next().?;

    for (first_line, 0..) |c, i| {
        if (c == 'S') {
            try set.put(i, 1);
            break;
        }
    }

    var skip = true;
    while (lines_it.next()) |line| {
        if (line.len <= 0) break;
        if (skip) {
            skip = false;
            continue;
        } else {
            skip = true;
        }

        var it = set.iterator();
        while (it.next()) |e| {
            const idx = e.key_ptr.*;
            const parent_value = e.value_ptr.*;

            const c = line[idx];
            if (c == '^') {
                const left = try next_set.getOrPut(idx - 1);
                if (left.found_existing) {
                    left.value_ptr.* += parent_value;
                } else {
                    left.value_ptr.* = parent_value;
                }
                const right = try next_set.getOrPut(idx + 1);
                if (right.found_existing) {
                    right.value_ptr.* += parent_value;
                } else {
                    right.value_ptr.* = parent_value;
                }
            } else {
                const pos = try next_set.getOrPut(idx);
                if (pos.found_existing) {
                    pos.value_ptr.* += parent_value;
                } else {
                    pos.value_ptr.* = parent_value;
                }
            }
        }
        std.mem.swap(std.AutoHashMap(Key, usize), &set, &next_set);
        next_set.clearRetainingCapacity();
    }

    var it = set.iterator();
    var sum: usize = 0;
    while (it.next()) |v| {
        sum += v.value_ptr.*;
    }

    std.debug.print("{d}\n", .{sum});
}
