// --- Day 2: Red-Nosed Reports ---

const std = @import("std");
const Chameleon = @import("chameleon");

fn isSafe(reportlist: *std.ArrayList(i32), recursed: bool) !bool {
    var is_increasing: ?bool = null;
    var last: ?i32 = null;
    const report = reportlist.items;

    for (report, 0..) |num, index| {
        if (last != null) {
            const diff = num - last.?;

            if (is_increasing == null) {
                // is_increasing will get a value if the numbers are the same,
                // but that's an unsafe report so who cares
                is_increasing = last.? < num;
            }

            //std.debug.print("num {d}, last{d}, diff{d}, is_increasing:{any}\n", .{ num, last.?, diff, is_increasing });

            if (!if (is_increasing.?) 1 <= diff and diff <= 3 else -3 <= diff and diff <= -1) {
                //std.debug.print("bad. with{any} without{any}{any}\n", .{ report, report[0 .. index - 1], report[index..] });

                if (!recursed) {
                    var report0 = try reportlist.clone();
                    var report1 = try reportlist.clone();
                    var report2 = try reportlist.clone();
                    defer report0.deinit();
                    defer report1.deinit();
                    defer report2.deinit();
                    if (index >= 2) {
                        _ = report2.orderedRemove(index - 2);
                        _ = report1.orderedRemove(index - 1);
                        _ = report0.orderedRemove(index);
                    } else if (index == 1) {
                        _ = report1.orderedRemove(index - 1);
                        _ = report0.orderedRemove(index);
                    } else {
                        _ = report0.orderedRemove(index);
                    }
                    const newone = try isSafe(&report0, true) or try isSafe(&report1, true) or try isSafe(&report2, true);
                    //std.debug.print("{any}bad. trying{any} and{any}: {any}\n", .{ report, report0.items, report1.items, newone });
                    return newone;
                } else {
                    return false;
                }
            }
        }

        last = num;
    }
    return true;
}

fn get_nums(line: []const u8, nums: *std.ArrayList(i32)) !void {
    var l = std.mem.splitAny(u8, line, " ");

    while (l.next()) |num| {
        if (num.len == 0) {
            continue;
        } else {
            try nums.append(try std.fmt.parseInt(i32, num, 0));
        }
    }
}

pub fn day2(allocator: std.mem.Allocator, file: *std.ArrayList([]u8)) !void {
    // TODO: don't know how to pass this in as a pointer instead
    var cham = Chameleon.initRuntime(.{ .allocator = allocator });
    defer cham.deinit();

    var nums = std.ArrayList(i32).init(allocator);
    defer nums.deinit();

    var total_safe: u32 = 0;
    var total_safe2: u32 = 0;
    for (file.items) |line| {
        try get_nums(line, &nums);
        const is_safe = try isSafe(&nums, true);
        const is_safe2 = try isSafe(&nums, false);
        total_safe += if (is_safe) 1 else 0;
        total_safe2 += if (is_safe2) 1 else 0;
        try cham.red().printErr("nums{any}, is_safe:{any}, is_safe2:{any}\n", .{ nums.items, is_safe, is_safe2 });
        nums.clearAndFree();
    }
    try cham.cyan().bold().printErr("total number safe: {d} part 2: {d}\n", .{ total_safe, total_safe2 });
}
