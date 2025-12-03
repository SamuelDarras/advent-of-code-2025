const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\987654321111111
//     \\811111111111119
//     \\234234234234278
//     \\818181911112111
//     \\
// ;

pub fn main() !void {
    var lines = std.mem.splitAny(u8, SRC, "\n");

    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len <= 1) break;
        var max1: usize = 0;
        var max1_idx: usize = 0;
        var max2: usize = 0;

        for (0..line.len - 1) |i| {
            if (line[i] > max1) {
                max1 = line[i];
                max1_idx = i;
            }
        }
        for (max1_idx + 1..line.len) |i| {
            if (line[i] > max2) {
                max2 = line[i];
            }
        }

        const joltage = (max1 - '0') * 10 + (max2 - '0');
        sum += joltage;
    }

    std.debug.print("{d}\n", .{sum});
}
