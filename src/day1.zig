// --- Day 1: Historian Hysteria ---

const std = @import("std");
const Chameleon = @import("chameleon");

fn sub_abs(a: i32, b: i32) i32 {
    return if (a - b >= 0) a - b else b - a;
}

fn get_2nums(line: []const u8) !struct { i32, i32 } {
    var l = std.mem.splitAny(u8, line, " ");

    // Start null, get populated
    var first: ?i32 = null;
    var last: ?i32 = null;

    while (l.next()) |num| {
        if (num.len == 0) {
            continue;
        } else {
            if (first != null) {
                last = try std.fmt.parseInt(i32, num, 0);
            } else {
                first = try std.fmt.parseInt(i32, num, 0);
            }
        }
    }
    return .{ first.?, last.? };
}

fn sort_and_subtract(first: []i32, second: []i32) i32 {
    std.mem.sort(i32, first, {}, std.sort.desc(i32));
    std.mem.sort(i32, second, {}, std.sort.desc(i32));
    //desc(comptime T: type) fn (void, T, T) bool
    //std.mem.sort(phand, list.items, {}, phandLessThan);
    //pub fn sort( comptime T: type, items: []T, context: anytype, comptime lessThanFn: fn (@TypeOf(context), lhs: T, rhs: T) bool, ) void

    var total: i32 = 0;
    for (first, second) |f, s| {
        total += sub_abs(f, s);
    }
    return total;
}

fn count_similarity(first: []i32, second: []i32) i32 {
    //pub fn count(comptime T: type, haystack: []const T, needle: []const T) usize

    var similarity: i32 = 0;
    for (first) |f| {
        const f_array = [_]i32{f};
        const sim: i32 = @intCast(std.mem.count(i32, second, &f_array));
        const mult = f * sim;
        similarity += mult;
        //std.debug.print("f: {d}, sim: {d}, mult: {d}, similarity: {d}\n", .{ f, sim, mult, similarity });
    }
    return similarity;
}

pub fn day1(allocator: std.mem.Allocator, file: *std.ArrayList([]u8)) !void {
    // TODO: don't know how to pass this in as a pointer instead
    var cham = Chameleon.initRuntime(.{ .allocator = allocator });
    defer cham.deinit();

    var first = std.ArrayList(i32).init(allocator);
    var second = std.ArrayList(i32).init(allocator);

    for (file.items) |line| {
        const poop: struct { i32, i32 } = try get_2nums(line);
        try cham.red().bold().printErr("{d}.{d}, line: {s}\n", .{ poop[0], poop[1], line });
        try first.append(poop[0]);
        try second.append(poop[1]);
    }
    try cham.green().printErr("arraylist first: {any}\n", .{first.items});
    try cham.green().printErr("arraylist second: {any}\n", .{second.items});

    const total = sort_and_subtract(first.items, second.items);
    try cham.cyan().bold().printErr("total: {d}\n", .{total});

    const similarity = count_similarity(first.items, second.items);
    try cham.cyan().bold().printErr("similarity: {d}\n", .{similarity});
}
