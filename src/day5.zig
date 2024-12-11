// --- Day 3: Mull It Over ---

const std = @import("std");
const Chameleon = @import("chameleon");

const rule = struct { before: u32, after: u32 };

fn get_rule(line: []const u8) rule {
    var l = std.mem.splitAny(u8, line, "|");

    // Start null, get populated
    var first: ?u32 = null;
    var last: ?u32 = null;

    while (l.next()) |num| {
        if (num.len == 0) {
            continue;
        } else {
            if (first != null) {
                last = std.fmt.parseInt(u32, num, 0) catch 0;
            } else {
                first = std.fmt.parseInt(u32, num, 0) catch 0;
            }
        }
    }
    return rule{ .before = first.?, .after = last.? };
}

pub fn day5(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    var rules = std.ArrayList(rule).init(allocator);
    defer rules.deinit();

    var total: u32 = 0;
    var doing_rules = true;

    for (file.items) |line| {
        try cham.yellow().printOut("{s}\n", .{line});
        total += 1;
        if (line.len == 0) {
            doing_rules = false;
            try cham.blue().printOut("done with rules:{any}\n", .{rules.items});
        }

        if (doing_rules) {
            try rules.append(get_rule(line));
        }
    }

    try cham.cyan().bold().printOut("total part 2:{d}\n", .{total});
}
