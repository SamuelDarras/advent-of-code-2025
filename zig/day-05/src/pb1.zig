const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\3-5
//     \\10-14
//     \\16-20
//     \\12-18
//     \\
//     \\1
//     \\5
//     \\8
//     \\11
//     \\17
//     \\32
// ;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var ranges = try std.ArrayList(struct { usize, usize }).initCapacity(alloc, 64);
    defer ranges.deinit(alloc);

    var ids = try std.ArrayList(usize).initCapacity(alloc, 64);
    defer ids.deinit(alloc);

    var lines = std.mem.splitAny(u8, SRC, "\n");

    var in_ranges = true;
    while (lines.next()) |line| {
        if (line.len == 0 and !in_ranges) break;

        if (in_ranges) {
            if (line.len == 0) {
                in_ranges = false;
                continue;
            }

            var bounds = std.mem.splitAny(u8, line, "-");
            try ranges.append(alloc, .{ try std.fmt.parseInt(usize, bounds.next().?, 10), try std.fmt.parseInt(usize, bounds.next().?, 10) });
        } else {
            try ids.append(alloc, try std.fmt.parseInt(usize, line, 10));
        }
    }

    var count: usize = 0;
    for (ids.items) |id| {
        for (ranges.items) |range| {
            if (id >= range.@"0" and id <= range.@"1") {
                count += 1;
                break;
            }
        }
    }

    std.debug.print("{d}\n", .{count});
}
