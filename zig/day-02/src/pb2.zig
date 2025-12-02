const std = @import("std");

const SRC = @embedFile("./src2.txt");
// const SRC = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

pub fn main() !void {
    const line = std.mem.trim(u8, SRC, "\n");
    var ranges = std.mem.splitAny(u8, line, ",");

    const alloc = std.heap.page_allocator;
    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = alloc, .n_jobs = try std.Thread.getCpuCount() });
    defer pool.deinit();

    var wg = std.Thread.WaitGroup{};

    var acc: usize = 0;

    while (ranges.next()) |range| {
        const split_index = std.mem.indexOf(u8, range, "-").?;
        const lo = try std.fmt.parseInt(usize, range[0..split_index], 10);
        const hi = try std.fmt.parseInt(usize, range[split_index + 1 ..], 10);

        pool.spawnWg(&wg, check_one_range, .{ lo, hi, &acc });
    }
    wg.wait();

    std.debug.print("{d}\n", .{acc});
}

fn check_one_range(lo: usize, hi: usize, acc: *usize) void {
    var buf: [256]u8 = undefined;

    for (lo..hi + 1) |n| {
        const s = std.fmt.bufPrint(&buf, "{d}", .{n}) catch return;

        // Iterating from longer to smaller pattern length means less iterations
        // for longer numbers, wich are less likely to repeat a lot.
        var len = (s.len / 2) + 1;
        while (len > 1) : (len -= 1) {
            if (check_repeat_len(s, len)) {
                // Perform atomic Read Modify Write: acc += n
                _ = @atomicRmw(usize, acc, .Add, n, .seq_cst);
                break;
            }
        }
    }
}

fn check_repeat_len(slice: []const u8, len: usize) bool {
    // If the number cannot be split exacly in n parts, return false.
    if (slice.len % len != 0) return false;

    const left = slice[0..len];
    for (1..slice.len / len) |pattern_idx| {
        const right = slice[len * pattern_idx .. len * (pattern_idx + 1)];
        if (!std.mem.eql(u8, left, right)) return false;
    }
    return true;
}
