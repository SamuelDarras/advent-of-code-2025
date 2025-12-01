const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\L68
//     \\L30
//     \\R48
//     \\L5
//     \\R60
//     \\L55
//     \\L1
//     \\L99
//     \\R14
//     \\L82
//     \\
// ;

pub fn main() !void {
    var it = std.mem.splitAny(u8, SRC, "\n");

    var dial: i32 = 50;
    var zeroes: usize = 0;

    while (it.next()) |line| {
        if (line.len <= 1) break;

        const direction: i32 = switch (line[0]) {
            'L' => -1,
            'R' => 1,
            else => unreachable,
        };

        const amount = try std.fmt.parseInt(i32, line[1..], 10);

        dial = @mod(dial + direction * amount, 100);

        if (dial == 0)
            zeroes += 1;
    }
    std.debug.print("zeroes = {d}", .{zeroes});
}
