const std = @import("std");

const SRC = @embedFile("./src2.txt");
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

const Range = packed struct { start: usize, end: usize };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var lines = std.mem.splitAny(u8, SRC, "\n");

    var ranges = std.ArrayList(Range){};
    defer ranges.deinit(alloc);

    var in_ranges = true;
    while (lines.next()) |line| {
        if (line.len == 0) break;

        if (in_ranges) {
            if (line.len == 0) {
                in_ranges = false;
                continue;
            }

            var bounds = std.mem.splitAny(u8, line, "-");
            try ranges.append(alloc, .{ .start = try std.fmt.parseInt(usize, bounds.next().?, 10), .end = try std.fmt.parseInt(usize, bounds.next().?, 10) });
        }
    }

    const final_ranges = try mergeRanges(alloc, ranges.items);
    defer alloc.free(final_ranges);

    var count: usize = 0;
    {
        for (final_ranges) |range| {
            count += range.end - range.start + 1;
        }
    }

    std.debug.print("{d}\n", .{count});
}

fn rangeLessThan(_: void, a: Range, b: Range) bool {
    return a.start < b.start or (a.start == b.start and a.end < b.end);
}

pub fn mergeRanges(
    allocator: std.mem.Allocator,
    input: []const Range,
) ![]Range {
    var list = std.ArrayList(Range).empty;
    defer list.deinit(allocator);

    try list.appendSlice(allocator, input);

    std.mem.sort(Range, list.items, {}, rangeLessThan);

    var result = std.ArrayList(Range){};

    var i: usize = 0;
    while (i < list.items.len) : (i += 1) {
        var current = list.items[i];

        while (i + 1 < list.items.len and
            list.items[i + 1].start <= current.end)
        {
            const next = list.items[i + 1];
            if (next.end > current.end) {
                current.end = next.end;
            }
            i += 1;
        }

        try result.append(allocator, current);
    }

    return result.toOwnedSlice(allocator);
}
