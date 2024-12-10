// --- Day 3: Mull It Over ---

const std = @import("std");
const Chameleon = @import("chameleon");

fn get_muls(line: []const u8, cham: *Chameleon.RuntimeChameleon, do: *bool, part2: bool) !u64 {
    var total: u64 = 0;
    const mul_str = "mul(";
    const do_str = "do()";
    const dont_str = "don't()";
    try cham.cyan().printErr("line: {s}\n", .{line});

    var index: u32 = 0;
    var index_beg: u32 = 0;
    //var do: bool = true;
    try cham.yellow().bold().printErr("do len: {d} don't len: {d}\n", .{ do_str.len, dont_str.len });
    while (index < line.len) {
        //const char = line[index];

        if (index < line.len - do_str.len and std.mem.eql(u8, line[index .. index + do_str.len], do_str)) {
            do.* = true;
            try cham.magenta().bold().printErr("{s} DISCOVERED index: {d}\n", .{ line[index .. index + do_str.len], index });
        }
        if (index < line.len - dont_str.len and std.mem.eql(u8, line[index .. index + dont_str.len], dont_str)) {
            do.* = false;
            try cham.magenta().bold().printErr("{s} DISCOVERED index: {d}\n", .{ line[index .. index + dont_str.len], index });
        }

        // Look for "mul)"
        if ((do.* or !part2) and index < line.len - 4 and std.mem.eql(u8, line[index .. index + 4], mul_str)) {
            //try cham.magenta().bold().printErr("MUL DISCOVERED index: {d}\n", .{index});
            index_beg = index;
            index += 4;
            const num1success = for (0..4) |num1index| { // i want 2, 1, 0 in the loop TODO
                if (index + num1index >= line.len) {
                    break 0;
                }
                switch (line[index + num1index]) {
                    '0'...'9' => {
                        continue;
                    },
                    else => {
                        break num1index;
                    },
                }
            } else 0;
            const num1strreal = line[index .. index + num1success];
            index += @intCast(num1success);

            // Check for 3 digit number and ','
            if (num1success == 0 or line[index] != ',') {
                continue;
            }
            // index the ','
            index += 1;
            // Look for 1-3 digit number
            const num2success = for (0..4) |num2index| {
                if (index + num2index >= line.len) {
                    break 0;
                }
                switch (line[index + num2index]) {
                    '0'...'9' => {
                        continue;
                    },
                    else => {
                        break num2index;
                    },
                }
            } else 0;
            const num2strreal = line[index .. index + num2success];
            index += @intCast(num2success);

            // Check for 3 digit number and ')'
            if (num2success == 0 or line[index] != ')') {
                continue;
            }

            // Success!
            //try cham.yellow().bold().printErr("{s} num1:{s}, num2:{s}\n", .{ line[index_beg .. index + 1], num1strreal, num2strreal });
            const n1 = try std.fmt.parseInt(u32, num1strreal, 0);
            const n2 = try std.fmt.parseInt(u32, num2strreal, 0);
            try cham.white().bold().printErr("{s}\ti: {d}, num1:{s}, num2:{s}, {d} {d}\n", .{ line[index_beg .. index + 1], index, num1strreal, num2strreal, n1, n2 });
            total += n1 * n2;

            // reset for next one
        }
        //try cham.yellow().printErr("char: {c}, index: {d}\n", .{ char, index });
        index += 1;
    }
    return total;
}

pub fn day3(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    var nums = std.ArrayList(i32).init(allocator);
    defer nums.deinit();

    var total: u64 = 0;
    var total_part2: u64 = 0;
    var do: bool = true;
    var do2: bool = true;
    for (file.items) |line| {
        total += try get_muls(line, cham, &do, false);
        total_part2 += try get_muls(line, cham, &do2, true);
        //try cham.red().printErr("nums{any}, is_safe:{any}, is_safe2:{any}\n", .{ nums.items, is_safe, is_safe2 });
    }
    try cham.cyan().bold().printOut("total muls: {d} part2: {d}\n", .{ total, total_part2 });
}
