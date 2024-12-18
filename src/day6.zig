// --- Day 5: Print Queue ---

const std = @import("std");
const Chameleon = @import("chameleon");

const Dir = enum { up, down, left, right };
const Coord = struct { x: u8, y: u8, dir: Dir };

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

    cham.cyan().printOut("grid lens {d} {d} taking step from {any} toward step {any}\n", .{ grid.len, grid[0].len, guard, new_step }) catch {};
    if (isStepPossible(grid, new_step)) {
        return new_step;
    }

    const rotated_step = Coord{ .x = guard.x, .y = guard.y, .dir = rotate(guard.dir) };
    return takeStep(grid, rotated_step, cham);
}

pub fn day6(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    //pub fn initCapacity(allocator: Allocator, num: usize) Allocator.Error!Self
    const grid = file.items;

    var visitedset = std.BufSet.init(allocator);
    defer visitedset.deinit();

    var total: u32 = 0;

    for (file.items) |line| {
        try cham.yellow().printOut("{s}\n", .{line});
    }

    var guard: Coord = try findGuard(grid);
    while (takeStep(grid, guard, cham)) |new_guard| {
        const coord_array = [_]u8{ new_guard.x, new_guard.y };
        if (!visitedset.contains(&coord_array)) {
            try visitedset.insert(&coord_array);
            total += 1;
        }
        guard = new_guard;
    }

    try cham.cyan().bold().printOut("total:{d}\n", .{total});
}
