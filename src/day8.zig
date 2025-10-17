// --- Day 8: Resonant Collinearity ---

const std = @import("std");
const Chameleon = @import("chameleon");

// Note: this point has y first because we loop through grid by rows then by points(columns)
// so y is ROW and x is COLUMN
const Point = struct { y: u8, x: u8 };

fn isOnMap(x: i32, y: i32, max_limit: Point) bool {
    return x >= 0 and y >= 0 and x < max_limit.x and y < max_limit.y;
}

fn getNewPoint(diff_x: i16, diff_y: i16, point: Point, max_limit: Point) ?Point {
    const x = point.x + diff_x;
    const y = point.y + diff_y;
    return if (isOnMap(x, y, max_limit)) Point{.x=@intCast(x), .y=@intCast(y)} else null;
}

// takes a point and a hashmap. Tries to add it. Returns how many points added to the hashmap (0 or 1)
fn addAN(an: Point, all_an: *std.AutoHashMap(Point, void), cham: *Chameleon.RuntimeChameleon) u1 {
    // add to hashmap
    if (all_an.contains(an)) {
        cham.red().bold().printOut("all_an already has antinode an! ({d},{d})\n", .{an.x, an.y}) catch unreachable;
        return 0;
    } else {
        all_an.put(an, {}) catch unreachable;
        cham.yellow().bold().printOut("antinode an: ({d},{d})\n", .{an.x, an.y}) catch unreachable;
        return 1;
    }
}

fn getPart2Antinodes(max_limit: Point, hashmap: std.AutoHashMap(u8, std.ArrayList(Point)), all_antinodes: *std.AutoHashMap(Point, void), cham: *Chameleon.RuntimeChameleon) !u16 {
    var iterator = hashmap.valueIterator();

    var num_antinodes: u16 = 0;
    while (iterator.next()) |antenna_list| {
        // Now loop through array in a way to get every pair of items in it
        // Get the antinodes for them.
        // Add them to a set
        for (antenna_list.items, 0..) |a, idx1| {
            for (antenna_list.items, 0..) |b, idx2| {
                if (idx2 <= idx1) {
                    continue;
                }
                cham.white().bold().printOut("{d}({d},{d})   {d}({d},{d})\n", .{idx1, a.x, a.y, idx2, b.x, b.y}) catch unreachable;

                // Ok we have all the combos. Now to get the antinodes
                // Just putting it in the while loop instead of a new function passing pointers. Easier that way

                // a - b is the difference.
                // a + diff goes up
                // b - diff goes down (or b + -diff)
                const diff_x: i16 = @as(i16, a.x) - @as(i16, b.x);
                const diff_y: i16 = @as(i16, a.y) - @as(i16, b.y);

                const diff_x_neg: i16 = -1 * diff_x;
                const diff_y_neg: i16 = -1 * diff_y;

                // a + diff
                num_antinodes += addAN(a, all_antinodes, cham);
                var new_antinode = a;
                while(getNewPoint(diff_x, diff_y, new_antinode, max_limit)) |new_an| {
                    new_antinode = new_an;
                    num_antinodes += addAN(new_antinode, all_antinodes, cham);
                }

                // b - diff
                num_antinodes += addAN(b, all_antinodes, cham);
                new_antinode = b;
                while(getNewPoint(diff_x_neg, diff_y_neg, new_antinode, max_limit)) |new_an| {
                    new_antinode = new_an;
                    num_antinodes += addAN(new_antinode, all_antinodes, cham);
                }
            }
        }
    }
    cham.magenta().bold().printOut("num antinodes for part 2: {d}\n", .{num_antinodes}) catch unreachable;
    return num_antinodes;
}

fn getPart1ANPair(a: Point, b: Point, max_limit: Point, cham: *Chameleon.RuntimeChameleon) struct{?Point, ?Point} {
    _ = cham;

    const diff_x: i16 = @as(i16, a.x) - @as(i16, b.x);
    const diff_y: i16 = @as(i16, a.y) - @as(i16, b.y);

    const a_x: i16 = a.x + diff_x;
    const a_y: i16 = a.y + diff_y;

    const b_x: i16 = b.x - diff_x;
    const b_y: i16 = b.y - diff_y;

    const antinode_a = if (isOnMap(a_x, a_y, max_limit)) Point{.x = @intCast(a_x), .y = @intCast(a_y)} else null;
    const antinode_b = if (isOnMap(b_x, b_y, max_limit)) Point{.x = @intCast(b_x), .y = @intCast(b_y)} else null;

    return .{antinode_a, antinode_b};
}

fn getPart1Antinodes(max_limit: Point, hashmap: std.AutoHashMap(u8, std.ArrayList(Point)), allAntennas: *std.AutoHashMap(Point, void), cham: *Chameleon.RuntimeChameleon) !u16 {
    var iterator = hashmap.valueIterator();

    var num_antinodes: u16 = 0;
    while (iterator.next()) |antenna_list| {
        // Now loop through array in a way to get every pair of items in it
        // Get the antinodes for them.
        // Add them to a set

        for (antenna_list.items, 0..) |ant1, idx1| {
            for (antenna_list.items, 0..) |ant2, idx2| {
                if (idx2 <= idx1) {
                    continue;
                }
                cham.white().bold().printOut("{d}({d},{d})   {d}({d},{d})\n", .{idx1, ant1.x, ant1.y, idx2, ant2.x, ant2.y}) catch unreachable;

                // Ok we have all the combos. Now to get the antinodes
                const antinodes = getPart1ANPair(ant1, ant2, max_limit, cham);
                const a0 = antinodes[0];
                const a1 = antinodes[1];

                // Antinode exists and isn't overlapping an antenna
                if(a0 != null) {
                    if (allAntennas.contains(a0.?)) {
                        cham.red().bold().printOut("allAntennas already has antinode a0! ({d},{d})\n", .{a0.?.x, a0.?.y}) catch unreachable;
                    } else {
                        num_antinodes+=1;
                        try allAntennas.put(a0.?, {});
                        cham.yellow().bold().printOut("antinode a0: ({d},{d})\n", .{a0.?.x, a0.?.y}) catch unreachable;
                    }
                }
                // Antinode exists and isn't overlapping an antenna
                if(a1 != null) {
                    if (allAntennas.contains(a1.?)) {
                        cham.red().bold().printOut("allAntennas already has antinode a1! ({d},{d})\n", .{a1.?.x, a1.?.y}) catch unreachable;
                    } else {
                        num_antinodes+=1;
                        try allAntennas.put(a1.?, {});
                        cham.yellow().bold().printOut("antinode a1: ({d},{d})\n", .{a1.?.x, a1.?.y}) catch unreachable;
                    }
                }
            }
        }
    }
    cham.magenta().bold().printOut("num antinodes: {d}\n", .{num_antinodes}) catch unreachable;
    return num_antinodes;
}

fn isAntenna(character: u8) bool {
    return switch (character) {
        '0'...'9', 'a'...'z', 'A'...'Z' => true,
        else                            => false,
    };
}

fn hashmapDeinit(hashmap: *std.AutoHashMap(u8, std.ArrayList(Point)), cham: *Chameleon.RuntimeChameleon) void {
    //cham.green().bold().printOut("deiniting the hashmap {any}\n", .{hashmap}) catch unreachable;
    //fn equations_deinit(equations: *std.ArrayList(Equation), cham: *Chameleon.RuntimeChameleon) void {
    var iterator = hashmap.valueIterator();
    while (iterator.next()) |antenna_list| {
        //cham.yellow().bold().printOut("deiniting {any}\n", .{antenna_list.items}) catch unreachable;
        antenna_list.deinit();
    }
    //cham.cyan().bold().printOut("deiniting the hashmap {any}\n", .{hashmap}) catch unreachable;
    _ = cham;
    hashmap.deinit();
}

pub fn day8(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    const grid = file.items;
    const y_limit = file.items.len;
    const x_limit = file.items[0].len;
    const max_limit: Point = Point{.x=@intCast(x_limit), .y=@intCast(y_limit)};
    try cham.yellow().bold().printOut("max size: {d},{d}\n", .{x_limit, y_limit});


    var hashmap = std.AutoHashMap(u8, std.ArrayList(Point)).init(allocator);
    defer hashmapDeinit(&hashmap, cham);

    // Using hashmap as a set
    var allAntennas = std.AutoHashMap(Point, void).init(allocator);
    defer allAntennas.deinit();

    // Go through grid and
    // 1. determine the different types of antennas
    // 2. save each antenna according to its type
    for (grid, 0..) |row, row_index| {
        try cham.yellow().printOut("{s}\n", .{row});

        for (row, 0..) |character, col_index| {
            if (isAntenna(character)) {
                // Create the point
                const point: Point = Point{.y = @intCast(row_index), .x = @intCast(col_index)};

                // This was actually the wrong thing to do. I don't need a master list of the antennas.
                //try allAntennas.put(point, {}); // a literal void value rather than the void type

                // Get the list of points for this antenna type (make a new one if needed)
                // I was trying to figure out how to have the if statement produce
                // the Arraylist like
                // var antenna_list = if(present) hashmap.find() else std.Arraylist().init()
                // but in the else case we have to add the list to the hashmap first, and I dunno
                // how to do that as a simple expression. Maybe addifnotexists?
                // Ah but I don't want to make a new arraylist if I don't have to.
                var antenna_list: *std.ArrayList(Point) = undefined;
                if (hashmap.getPtr(character)) |antenna| {
                    antenna_list = antenna;
                } else {
                    // This is so clunky. Calling getPtr AGAIN. But I dunno how else to do it
                    // This will get deinit() when the hashmap does
                    try hashmap.put(character, std.ArrayList(Point).init(allocator)); // hmm it will be modified after this put. Is that ok?
                    antenna_list = hashmap.getPtr(character).?;
                }

                // Add the point to the correct list
                try antenna_list.append(point);

                // Because the arraylists have just been being copied, put the new arraylist into the hashmap
                // update: Fixed!
                //try hashmap.put(character, antenna_list);
                //cham.magenta().bold().printOut("appended {any} to {any}\n", .{point, antenna_list.items}) catch unreachable;
            }
        }
    }

    const num_antinodes1 = try getPart1Antinodes(max_limit, hashmap, &allAntennas, cham);

    // Using hashmap as a set
    var all_antinodes = std.AutoHashMap(Point, void).init(allocator);
    defer all_antinodes.deinit();

    const num_antinodes2 = try getPart2Antinodes(max_limit, hashmap, &all_antinodes, cham);

    cham.magenta().bold().printOut("num antinodes part 1: {d}\n", .{num_antinodes1}) catch unreachable;
    cham.magenta().bold().printOut("num antinodes part 2: {d}\n", .{num_antinodes2}) catch unreachable;
}


// Current status:
// I have all the antennas
// I am finding all the antinodes
// But I misunderstood - an antinode MAY exist at an antenna location
// but 2 antinodes in the same place only count as 1
// TODO: a location with antinodes for 2 different types counts as only 1 or 2 antennas?
