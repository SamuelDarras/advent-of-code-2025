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
//     \\L930
//     \\
// ;

pub fn main() !void {
    var it = std.mem.splitAny(u8, SRC, "\n");

    var model_dial: i32 = 50;
    var model_zeroes: usize = 0;

    while (it.next()) |line| {
        if (line.len <= 1) break;

        const direction: i32 = switch (line[0]) {
            'L' => -1,
            'R' => 1,
            else => unreachable,
        };

        const amount = try std.fmt.parseInt(i32, line[1..], 10);

        for (0..@intCast(amount)) |_| {
            if (direction == 1) {
                if (model_dial == 99) model_dial = 0 else model_dial += 1;
            } else {
                if (model_dial == 0) model_dial = 99 else model_dial -= 1;
            }
            if (model_dial == 0) {
                model_zeroes += 1;
            }
        }
    }
    std.debug.print("zeroes = {d}", .{model_zeroes});
}
