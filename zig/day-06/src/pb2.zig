const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\123 328  51 64
//     \\ 45 64  387 23
//     \\  6 98  215 314
//     \\*   +   *   +
//     \\
// ;
const LINE_COUNT: usize = 4;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();

    const line_length = std.mem.indexOf(u8, SRC, "\n").? + 1;
    const line_count = std.mem.count(u8, SRC, "\n") - 1;

    var col_symbol: u8 = ' ';
    var sum: usize = 0;
    var column_sum: usize = 0;
    var column_product: usize = 1;
    for (0..line_length - 1) |idx| {
        if (SRC[idx + line_length * line_count] == '+' or SRC[idx + line_length * line_count] == '*') col_symbol = SRC[idx + line_length * line_count];

        const is_break = blk: {
            var is_break = true;
            for (0..line_count + 1) |l| {
                is_break &= (SRC[idx + line_length * l] == ' ');
            }
            break :blk is_break;
        };
        if (is_break) {
            switch (col_symbol) {
                '+' => sum += column_sum,
                '*' => sum += column_product,
                else => unreachable,
            }
            column_sum = 0;
            column_product = 1;
        } else {
            const v = try value_from_col(alloc, idx, line_length, line_count);
            column_sum += v;
            column_product *= v;
        }
    }

    switch (col_symbol) {
        '+' => sum += column_sum,
        '*' => sum += column_product,
        else => unreachable,
    }
    column_sum = 0;
    column_product = 1;

    std.debug.print("{d}\n", .{sum});
}

fn value_from_col(alloc: std.mem.Allocator, idx: usize, len: usize, line_count: usize) !usize {
    var buffer = try std.ArrayList(u8).initCapacity(alloc, 16);
    defer buffer.deinit(alloc);

    for (0..line_count) |m| {
        try buffer.append(alloc, SRC[idx + m * len]);
    }

    return try std.fmt.parseInt(usize, std.mem.trim(u8, buffer.items, " "), 10);
}
