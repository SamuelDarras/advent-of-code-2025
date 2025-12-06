const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC =
//     \\123 328  51 64 
//     \\ 45 64  387 23 
//     \\  6 98  215 314
//     \\*   +   *   +
// ;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var columns = try std.ArrayList(struct { usize, usize }).initCapacity(alloc, 64);
    defer columns.deinit(alloc);

    var lines = std.mem.splitAny(u8, SRC, "\n");
    var operations: []const u8 = undefined;
    parse_numbers: while (lines.next()) |line_raw| {
        const line = std.mem.trim(u8, line_raw, " ");
        var line_index: usize = 0;
        var current_number_buffer: [64]u8 = undefined;
        var current_number_buffer_len: usize = 0;
        var column_idx: usize = 0;

        const State = enum {
            Digit,
            Other,
        };

        std.debug.print("`{s}`\n", .{line});

        sw: switch (State.Digit) {
            .Digit => {
                if (line[0] == '*' or line[0] == '+') {
                    operations = line;
                    break :parse_numbers;
                }
                if (line_index < line.len) {
                    std.debug.print(".Digit `{c}`\n", .{line[line_index]});
                }

                defer line_index += 1;

                if (line_index < line.len and std.ascii.isDigit(line[line_index])) {
                    current_number_buffer[current_number_buffer_len] = line[line_index];
                    current_number_buffer_len += 1;
                    continue :sw .Digit;
                } else {
                    const s = current_number_buffer[0..current_number_buffer_len];
                    std.debug.print("\tappend `{s}`\n", .{s});
                    const v = try std.fmt.parseInt(usize, s, 10);
                    if (column_idx < columns.items.len) {
                        columns.items[column_idx].@"0" += v;
                        columns.items[column_idx].@"1" *= v;
                    } else {
                        try columns.append(alloc, .{ v, v });
                    }
                    continue :sw .Other;
                }
            },
            .Other => {
                if (line_index >= line.len) break :sw;
                std.debug.print(".Other `{c}`\n", .{line[line_index]});

                defer line_index += 1;

                if (std.ascii.isDigit(line[line_index])) {
                    column_idx += 1;
                    current_number_buffer[0] = line[line_index];
                    current_number_buffer_len = 1;
                    continue :sw .Digit;
                } else {
                    continue :sw .Other;
                }
            },
        }
    }

    for (columns.items) |col| {
        std.debug.print("{d}, {d}\n", .{ col.@"0", col.@"1" });
    }

    var sum: usize = 0;
    var column_idx: usize = 0;
    for (operations) |operation| {
        if (operation == '+') {
            sum += columns.items[column_idx].@"0";
            column_idx += 1;
        }
        if (operation == '*') {
            sum += columns.items[column_idx].@"1";
            column_idx += 1;
        }
    }

    std.debug.print("{d}\n", .{sum});
}
