// --- Day 5: Print Queue ---

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

fn get_update(line: []const u8, update: *std.ArrayList(u32)) !void {
    var l = std.mem.splitAny(u8, line, ",");

    while (l.next()) |num| {
        if (num.len == 0) {
            continue;
        } else {
            try update.append(try std.fmt.parseInt(u32, num, 0));
        }
    }
}

fn naive_apply_rules_to_update(rules: []const rule, update: []const u32, cham: *Chameleon.RuntimeChameleon) !bool {
    for (rules) |r| {
        //pub fn indexOf(comptime T: type, haystack: []const T, needle: []const T) ?usize
        const b_array = [_]u32{r.before};
        const a_array = [_]u32{r.after};

        const before_index = std.mem.indexOf(u32, update, &b_array);
        const after_index = std.mem.indexOf(u32, update, &a_array);
        
        //try cham.white().printOut("{any}, {d}, {d}, success? indices {any} {any}\n", .{update, r.before, r.after, before_index, after_index});
        //try cham.gray().printOut("asdfasdf\n", .{});
        _ = cham;

        if (before_index == null or after_index == null) {
            continue;
        } 

        if(before_index.? >= after_index.?){
            return false;
        }
    }
    return true;
}

fn getMiddlePage(update: []const u32) u32 {
    const minusonehalf = (update.len - 1)/2;
    return update[minusonehalf];
}

pub fn day5(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    var rules = std.ArrayList(rule).init(allocator);
    defer rules.deinit();

    var total: u32 = 0;
    var doing_rules = true;

    for (file.items) |line| {
        try cham.yellow().printOut("{s}\n", .{line});
        if (line.len == 0) {
            doing_rules = false;
            try cham.blue().printOut("done with rules:{any}\n", .{rules.items});
            continue;
        }

        if (doing_rules) {
            try rules.append(get_rule(line));
        } else {
            var update = std.ArrayList(u32).init(allocator);
            defer update.deinit();
            try get_update(line, &update);
            try cham.green().printOut("update:{any}\n", .{update.items});

            if (try naive_apply_rules_to_update(rules.items, update.items, cham)) {
                const mp = getMiddlePage(update.items);
                total += mp;
                try cham.blue().printOut("success! middle page: {d}\n", .{mp});
            }

        }
    }

    try cham.cyan().bold().printOut("total:{d}\n", .{total});
}
