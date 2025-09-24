// --- Day 6: Print Queue ---

const std = @import("std");
const Chameleon = @import("chameleon");

const Dir = enum(u8) { up, down, left, right };
const Coord = struct { x: u8, y: u8, dir: Dir };

var print: bool = false;

fn findGuard(grid: [][]u8) !Coord {
    for (grid, 0..) |row, row_index| {
        for (row, 0..) |char, char_index| {
            if (char == '^') {
                return Coord{ .x = @intCast(char_index), .y = @intCast(row_index), .dir = Dir.up };
            }
        }
    }
    return error.noguard;
}

fn isStepPossible(grid: [][]u8, step: Coord) bool {
    switch (grid[step.y][step.x]) {
        '#' => {
            return false;
        },
        else => {
            return true;
        },
    }
}

fn isEmptySpace(grid: [][]u8, step: Coord) bool {
    switch (grid[step.y][step.x]) {
        '.' => {
            return true;
        },
        else => {
            return false;
        },
    }
}

fn rotate(dir: Dir) Dir {
    return switch (dir) {
        Dir.up => Dir.right,
        Dir.down => Dir.left,
        Dir.left => Dir.up,
        Dir.right => Dir.down,
    };
}

fn takeStep(grid: [][]u8, guard: Coord, cham: *Chameleon.RuntimeChameleon) ?Coord {
    if (guard.x == 0 and guard.dir == Dir.left) {
        // Walks off left of map
        return null;
    }
    if (guard.x == grid[0].len - 1 and guard.dir == Dir.right) {
        // Walks off right of map
        return null;
    }
    if (guard.y == grid.len - 1 and guard.dir == Dir.down) {
        // Walks off bottom of map
        return null;
    }
    if (guard.y == 0 and guard.dir == Dir.up) {
        // Walks off top of map
        return null;
    }

    const new_step = switch (guard.dir) {
        Dir.up => Coord{ .x = guard.x, .y = guard.y - 1, .dir = guard.dir },
        Dir.down => Coord{ .x = guard.x, .y = guard.y + 1, .dir = guard.dir },
        Dir.left => Coord{ .x = guard.x - 1, .y = guard.y, .dir = guard.dir },
        Dir.right => Coord{ .x = guard.x + 1, .y = guard.y, .dir = guard.dir },
    };

    if (print) {
        cham.cyan().printOut("step from {d},{d}, {any} \tto {d},{d}, {any}\n", .{ guard.x, guard.y, guard.dir, new_step.x, new_step.y, new_step.dir }) catch {};
    }
    if (isStepPossible(grid, new_step)) {
        // Step is possible! Take it
        return new_step;
    }

    // Step is not possible; rotate and try again
    const rotated_step = Coord{ .x = guard.x, .y = guard.y, .dir = rotate(guard.dir) };
    return takeStep(grid, rotated_step, cham);
}

fn runSim(allocator: std.mem.Allocator, grid: [][]u8, cham: *Chameleon.RuntimeChameleon) !struct{u32, u32, bool} {
    // The set of all locations the guard has visited
    var visitedset = std.BufSet.init(allocator);
    defer visitedset.deinit();
    // Record the visited location with directions
    var visitedsetdirs = std.BufSet.init(allocator);
    defer visitedsetdirs.deinit();

    var guard: Coord = try findGuard(grid);

    // Add the location the guard spawns in
    const start_location = [_]u8{ guard.x, guard.y };
    const start_location_dir = [_]u8{ guard.x, guard.y, @intFromEnum(guard.dir) };
    try visitedset.insert(&start_location);
    try visitedsetdirs.insert(&start_location_dir);

    //const guard_clone: Coord = try findGuard(grid);
    //const start_location_clone = [_]u8{ guard_clone.x, guard_clone.y, @intFromEnum(guard_clone.dir) };
    //if (visitedsetdirs.contains(&start_location_clone)) {
    //    try cham.green().printOut("This might just work\n", .{});
    //} else {
    //    try cham.red().printOut("Gotta try something else :(\n", .{});
    //}

    // Total number of visited placed starts at 1
    var total: u32 = 1;
    var total_dirs: u32 = 1;

    var is_infinite: bool = false;

    // Take steps until the guard walks off
    while (takeStep(grid, guard, cham)) |new_guard| {
        const coord_array = [_]u8{ new_guard.x, new_guard.y };
        const coord_array_dir = [_]u8{ new_guard.x, new_guard.y, @intFromEnum(new_guard.dir) };
        if (!visitedsetdirs.contains(&coord_array_dir)) {
            try visitedsetdirs.insert(&coord_array_dir);
            total_dirs += 1;
        } else {
            is_infinite = true;
            break;
        }
        if (!visitedset.contains(&coord_array)) {
            try visitedset.insert(&coord_array);
            total += 1;
        }
        guard = new_guard;
    }

    try cham.cyan().bold().printOut("total:{d}\t", .{total});
    try cham.cyan().bold().printOut("total_dirs:{d}\t", .{total_dirs});
    if (is_infinite) {
        try cham.red().bold().printOut("IS INFINITE\n", .{});
    } else {
        try cham.green().bold().printOut("is not infinite\n", .{});
    }

    return .{total, total_dirs, is_infinite};
}

pub fn day6(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    //pub fn initCapacity(allocator: Allocator, num: usize) Allocator.Error!Self
    var grid = file.items;

    // Print out the grid for funsies
    for (grid) |line| {
        try cham.yellow().printOut("{s}\n", .{line});
    }

    print = false;
    var result = try runSim(allocator, grid, cham);
    const total = result[0];
    const total_dirs = result[1];
    const is_infinite = result[2];

    try cham.cyan().bold().printOut("total:{d}\n", .{total});
    try cham.cyan().bold().printOut("total_dirs:{d}\n", .{total_dirs});
    if (is_infinite) {
        try cham.red().bold().printOut("IS INFINITE\n", .{});
    } else {
        try cham.green().bold().printOut("is not infinite\n", .{});
    }

    var infinity_count: u32 = 0;
    print = false;
    for (grid, 0..) |row, row_index| {
        for (row, 0..) |char, char_index| {
            if (char == '.') {
                try cham.yellow().bold().printOut("adding block at {d},{d}\t", .{row_index, char_index});
                grid[row_index][char_index] = '#';
                //for (grid) |line| {
                //    try cham.yellow().printOut("{s}\n", .{line});
                //}
                result = try runSim(allocator, grid, cham);
                if (result[2] == true) {
                    infinity_count += 1;
                }
                grid[row_index][char_index] = '.';
            }
        }
    }
    try cham.yellow().bold().printOut("\nTotal infinity count: {d}\n", .{infinity_count});

    // Current status: I think this works, but it takes too long. Like I would expect it to take an hour long. Waitable, but there's probably a faster way
}

