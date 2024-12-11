// --- Day 3: Mull It Over ---

const std = @import("std");
const Chameleon = @import("chameleon");

fn getForward(line: []u8) u32 {
    return @intCast(std.mem.count(u8, line, "XMAS"));
}

fn getBackward(line: []u8) u32 {
    return @intCast(std.mem.count(u8, line, "SAMX"));
}

fn day4_part1(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    var nums = std.ArrayList(i32).init(allocator);
    defer nums.deinit();

    var total: u32 = 0;
    for (file.items) |line| {
        try cham.white().bold().printOut("{s}\n", .{line});
    }

    // On each row, add forward and backwards
    for (file.items) |line| {
        const forward = getForward(line);
        const backward = getBackward(line);
        //try cham.green().printOut("row ", .{});
        //try cham.green().printOut("forwards: {d} backwards: {d}\n", .{ forward, backward });
        total += forward + backward;
    }

    // On each column, add forward and backwards
    for (0..file.items[0].len) |index_col| {
        var vert_line = std.ArrayList(u8).init(allocator);
        defer vert_line.deinit();

        for (0..file.items.len) |index_row| {
            try vert_line.append(file.items[index_row][index_col]);
        }

        const forward = getForward(vert_line.items);
        const backward = getBackward(vert_line.items);
        //try cham.green().printOut("col ", .{});
        //try cham.green().printOut("forwards: {d} backwards: {d}\n", .{ forward, backward });
        total += forward + backward;
    }

    // Top row, diagonal down right
    var i_row: i32 = 0;
    var i_col: u32 = 0;
    for (0..file.items[0].len) |index| {
        var diag_line = std.ArrayList(u8).init(allocator);
        defer diag_line.deinit();

        i_row = 0;
        i_col = @intCast(index);
        // Now go down and add all the characters at the index to the list
        while (i_col < file.items[0].len) {
            try diag_line.append(file.items[@intCast(i_row)][i_col]);
            i_row += 1;
            i_col += 1;
        }
        const forward = getForward(diag_line.items);
        const backward = getBackward(diag_line.items);
        //try cham.green().printOut("diag dr top row ", .{});
        //try cham.green().printOut("forwards: {d} backwards: {d}\n", .{ forward, backward });
        total += forward + backward;
    }

    // Going down the left side
    for (1..file.items.len) |index| {
        var diag_line = std.ArrayList(u8).init(allocator);
        defer diag_line.deinit();
        i_row = @intCast(index);
        i_col = 0;
        // Now go down and add all the characters at the index to the list
        while (i_row < file.items[0].len) {
            try diag_line.append(file.items[@intCast(i_row)][i_col]);
            i_row += 1;
            i_col += 1;
        }
        const forward = getForward(diag_line.items);
        const backward = getBackward(diag_line.items);
        //try cham.green().printOut("diag dr", .{});
        //try cham.green().printOut("forwards: {d} backwards: {d}\n", .{ forward, backward });
        total += forward + backward;
    }

    // Bottom row, diagonal up right
    for (0..file.items[0].len) |index| {
        var diag_line = std.ArrayList(u8).init(allocator);
        defer diag_line.deinit();

        i_row = @intCast(file.items[0].len - 1);
        i_col = @intCast(index);
        // Now go down and add all the characters at the index to the list
        while (i_col < file.items[0].len) {
            try diag_line.append(file.items[@intCast(i_row)][i_col]);
            i_row -= 1;
            i_col += 1;
        }
        const forward = getForward(diag_line.items);
        const backward = getBackward(diag_line.items);
        //try cham.green().printOut("diag ur bottom", .{});
        //try cham.green().printOut("forwards: {d} backwards: {d}\n", .{ forward, backward });
        total += forward + backward;
    }

    // Going down the left side, diagonal upwards
    for (0..file.items.len - 1) |index| {
        var diag_line = std.ArrayList(u8).init(allocator);
        defer diag_line.deinit();
        i_row = @intCast(index);
        i_col = 0;
        // Now go down and add all the characters at the index to the list
        while (i_row >= 0) {
            try diag_line.append(file.items[@intCast(i_row)][i_col]);
            i_row -= 1;
            i_col += 1;
        }
        const forward = getForward(diag_line.items);
        const backward = getBackward(diag_line.items);
        //try cham.green().printOut("diag ur", .{});
        //try cham.green().printOut("forwards: {d} backwards: {d}\n", .{ forward, backward });
        total += forward + backward;
    }

    try cham.cyan().bold().printOut("total {d}\n", .{total});
}

fn isMasX(input: [][]u8, x: u32, y: u32) bool {
    const top_for = input[x][y] == 'M' and input[x + 1][y + 1] == 'A' and input[x + 2][y + 2] == 'S';
    const top_bak = input[x][y] == 'S' and input[x + 1][y + 1] == 'A' and input[x + 2][y + 2] == 'M';
    const bot_for = input[x + 2][y] == 'M' and input[x + 1][y + 1] == 'A' and input[x][y + 2] == 'S';
    const bot_bak = input[x + 2][y] == 'S' and input[x + 1][y + 1] == 'A' and input[x][y + 2] == 'M';
    return (top_for or top_bak) and (bot_for or bot_bak);
}

fn day4_part2(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    var nums = std.ArrayList(i32).init(allocator);
    defer nums.deinit();

    var total: u32 = 0;

    // On each row, add forward and backwards
    for (0..file.items.len - 2) |row_index| {
        for (0..file.items[0].len - 2) |col_index| {
            if (isMasX(file.items, @intCast(row_index), @intCast(col_index))) {
                //try cham.yellow().printOut("masx found at {d},{d}\n", .{ row_index, col_index });
                total += 1;
            }
        }
    }

    try cham.cyan().bold().printOut("total part 2:{d}\n", .{total});
}

pub fn day4(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    _ = try day4_part1(allocator, file, cham);
    _ = try day4_part2(allocator, file, cham);
}
