const std = @import("std");

const SRC = @embedFile("./src2.txt");
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

        var max_idx: usize = 0;

        var joltage_str: [12]u8 = undefined;
        for (0..12) |battery| {
            var max: u8 = 0;

            const end_idx = line.len - 11 + battery;
            for (max_idx..end_idx) |i| {
                if (line[i] > max) {
                    max = line[i];
                    max_idx = i;
                }
            }
            max_idx += 1;
            joltage_str[battery] = max;
        }

        sum +=
            try std.fmt.parseInt(usize, &joltage_str, 10);
    }

    std.debug.print("{d}\n", .{sum});
}
