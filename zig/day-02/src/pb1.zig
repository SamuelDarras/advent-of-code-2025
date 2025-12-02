const std = @import("std");

const SRC = @embedFile("./src1.txt");
// const SRC = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

pub fn main() !void {
    var line = std.mem.splitAny(u8, SRC, "\n");
    var ranges = std.mem.splitAny(u8, line.first(), ",");

    var acc: usize = 0;

    while (ranges.next()) |range| {
        if (range.len <= 1) break;

        const split_index = std.mem.indexOf(u8, range, "-").?;
        const lo = try std.fmt.parseInt(usize, range[0..split_index], 10);
        const hi = try std.fmt.parseInt(usize, range[split_index + 1 ..], 10);

        var buf: [1024]u8 = undefined;
        for (lo..hi + 1) |n| {
            const s = try std.fmt.bufPrint(&buf, "{d}", .{n});

            if (s.len % 2 != 0) continue;
            if (std.mem.eql(u8, s[0 .. s.len / 2], s[s.len / 2 ..])) acc += n;
        }
    }

    std.debug.print("{d}", .{acc});
}
