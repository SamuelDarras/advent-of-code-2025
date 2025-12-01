const std = @import("std");

const SRC = @embedFile("./src2.txt");
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
//     \\L931
//     \\
// ;

pub fn main() !void {
    var it = std.mem.splitAny(u8, SRC, "\n");

    var dial: i32 = 50;
    var zeroes: usize = 0;

    while (it.next()) |line| {
        if (line.len <= 1) break;

        const amount = try std.fmt.parseInt(i32, line[1..], 10);

        const turns = @divFloor(amount, 100);
        const rotation = @mod(amount, 100);

        zeroes += @intCast(turns);
        if (line[0] == 'R') {
            if (dial + rotation >= 100) zeroes += 1;
            dial = @mod(dial + rotation, 100);
        } else {
            if (dial > 0 and (dial - rotation) <= 0) zeroes += 1;
            dial = @mod(dial - rotation, 100);
        }
    }
    std.debug.print("zeroes = {d}", .{zeroes});
}
