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
    const line_length = std.mem.indexOf(u8, SRC, "\n").? + 1;
    const line_count = std.mem.count(u8, SRC, "\n") - 1;

    var col_symbol: u8 = ' ';
    var sum: usize = 0;
    var column_sum: usize = 0;
    var column_product: usize = 1;
    for (0..line_length - 1) |idx| {
        const current_symbol = SRC[idx + line_length * line_count];
        if (current_symbol == '+' or current_symbol == '*') col_symbol = current_symbol;

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
            const v = try value_from_col(idx, line_length, line_count);
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

fn value_from_col(idx: usize, len: usize, line_count: usize) !usize {
    var sum: usize = 0;
    var power: usize = 1;
    for (0..line_count) |m| {
        const c = SRC[idx + (line_count - m - 1) * len];
        if (sum != 0 and c == ' ') break;
        if (c == ' ') continue;

        sum += power * (c - '0');
        power *= 10;
    }

    return sum;
}
