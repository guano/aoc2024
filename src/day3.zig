// 2023 --- Day 3: Gear Ratios ---

const std = @import("std");
const expect = std.testing.expect;
const stdout = std.io.getStdOut().writer();
const Chameleon = @import("chameleon");

const partNumber = struct { number: u64 = 0, line_index: u64 = 0, slice_index: [2]u64 = .{ 0, 0 }, validated: bool = false, gear_multiply: u64 = 1, gear_num: u32 = 0 };

// Parameters: schematic: 2d array of chars.
// list: arraylist of partNumbers to be populated.
// char_detect_fn: function to call to determine if the current character is in the word we are looking for
fn find_parts_list(schematic: [][]const u8, list: *std.ArrayList(partNumber), char_detect_fn: *const fn (u8) bool) !void {
    //std.debug.print("\nIN FUNCTION TypeOf list: {any}, TypeOf(std.ArrayList): {any}\n", .{ @TypeOf(list), @TypeOf(std.ArrayList) });
    //std.debug.print("\nIN FUNCTION TypeOf list.*: {any}, TypeOf(std.ArrayList): {any}\n", .{ @TypeOf(list.*), @TypeOf(std.ArrayList) });
    // TODO: why can we just do list.append()? Do we get a dereference for free?

    for (schematic, 0..) |line, line_index| {
        //std.debug.print("line {d}: {s}\n", .{ line_index, line });

        var in_number: bool = false;
        var cur_partnumber: partNumber = undefined;
        for (line, 0..) |char, char_index| {
            if (in_number) {
                // Currently parsing a number
                if (!char_detect_fn(char)) {
                    // Finished parsing a number
                    // end index is the index before this one
                    cur_partnumber.slice_index[1] = char_index;
                    try list.append(cur_partnumber);
                    cur_partnumber = undefined;
                    in_number = false;
                } else if (char_index == line.len - 1) {
                    // Still a number, but the end of a line
                    // end index is the current index
                    cur_partnumber.slice_index[1] = char_index + 1;
                    try list.append(cur_partnumber);
                    cur_partnumber = undefined;
                    in_number = false;
                } else {
                    // Still parsing a number
                    continue;
                }
            } else {
                // Not parsing a number
                if (char_detect_fn(char)) {
                    // Found a number!
                    cur_partnumber.line_index = line_index;
                    cur_partnumber.slice_index[0] = char_index;
                    in_number = true;

                    if (char_index == line.len - 1) {
                        // At the end of a line; 1-digit number
                        cur_partnumber.slice_index[1] = char_index + 1;
                        try list.append(cur_partnumber);
                        cur_partnumber = undefined;
                        in_number = false;
                    }
                } else {
                    // Still haven't found a number
                    continue;
                }
            }
        }
    }
    //std.debug.print("\nHow many stuff is now in the list? {any}\n", .{list.items});
}

fn find_number(schematic: [][]const u8) ![2]u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList(partNumber).init(allocator);
    std.debug.print("\nTypeOf list: {any}, TypeOf(std.ArrayList): {any}\n", .{ @TypeOf(list), @TypeOf(std.ArrayList) });
    defer list.deinit();

    var c = Chameleon.initRuntime(.{ .allocator = allocator });
    defer c.deinit();

    // Populate the parts list with all the numbers
    try find_parts_list(schematic, &list, &std.ascii.isDigit);

    // Populate the number in the parts in the list
    for (list.items, 0..) |item, index| {
        _ = item;
        const p = &list.items[index];
        p.*.number = try std.fmt.parseInt(u32, schematic[p.line_index][p.slice_index[0]..p.slice_index[1]], 0);
    }
    //std.debug.print("AFTER GETTING NUMBERS: {any}", .{list.items});

    // Now to cull the ones not touching a special character
    for (list.items, 0..) |item, index| {
        // To check around the number, need 1 less than smallest of slice and 1 more of largest slice, but not overflow off ends
        const sl0_less: ?u32 = if (item.slice_index[0] == 0) null else @intCast(item.slice_index[0] - 1);
        const sl1_more: ?u32 = if (item.slice_index[1] == schematic[0].len) null else @intCast(item.slice_index[1]); // No +1 because of how slice indexes work
        const sl1_more_really: ?u32 = if (item.slice_index[1] == schematic[0].len) null else @intCast(item.slice_index[1] + 1); // this has a +1 because it's a slice index not a real index
        const wider_slice_index: [2]u64 = .{ sl0_less orelse item.slice_index[0], sl1_more_really orelse item.slice_index[1] };

        const change_item = &list.items[index];

        // Line before the number
        if (item.line_index != 0) {
            const cur_index = item.line_index - 1;
            for (schematic[cur_index][wider_slice_index[0]..wider_slice_index[1]]) |char| {
                if (char != '.') {
                    // Not a . means a symbol. Validate and no need to continue checking
                    change_item.*.validated = true;
                }
            }
        }
        // Line of the number
        if (sl0_less != null and schematic[item.line_index][sl0_less.?] != '.') {
            // Not a . means a symbol. Validate and no need to continue checking
            change_item.*.validated = true;
            //break; // TODO: can put in a function and then return
        }
        if (sl1_more != null and schematic[item.line_index][sl1_more.?] != '.') {
            // Not a . means a symbol. Validate and no need to continue checking
            change_item.*.validated = true;
            //break; // TODO: can put in a function and then return
        }

        // Line after the number
        if (item.line_index != schematic[0].len - 1) {
            const cur_index = item.line_index + 1;
            for (schematic[cur_index][wider_slice_index[0]..wider_slice_index[1]]) |char| {
                if (char != '.') {
                    // Not a . means a symbol. Validate and no need to continue checking
                    change_item.*.validated = true;
                }
            }
        }
    }

    var countlist: u32 = 0;
    for (list.items) |item| {
        if (item.validated) {
            countlist += 1;
        }
    }

    var total: u64 = 0;
    for (list.items) |item| {
        //std.debug.print("{any}\t\t", .{item});
        if (item.validated) {
            total += item.number;
        }
    }
    std.debug.print("\nTotal numbers: {d}, validated numbers: {d}\n", .{ list.items.len, countlist });

    ///////////////////////////////////////////////////////////////////////////
    // Now for part 2: asterisk boogaloo
    var asslist = std.ArrayList(partNumber).init(allocator);
    defer asslist.deinit();

    //const isasterisk = struct{pub fn call(char: u8) bool {return char == '*'} }.call;
    //try find_parts_list(schematic, &asslist, &isasterisk);
    // The following could have been written like the above, but I wanted
    // to learn how anonymous functions worked.
    try find_parts_list(schematic, &asslist, struct {
        pub fn call(x: u8) bool {
            return x == '*';
        }
    }.call);

    // Asterisks don't have numbers. Make them all 0
    for (asslist.items, 0..) |item, index| {
        _ = item;
        // Huh. Apparently we didn't need to get a pointer and do all that
        //&asslist.items[index];
        //p.*.number = 0;
        asslist.items[index].number = 0;
    }
    //std.debug.print("\n{any}\n", .{asslist.items});

    // TODO: we have the list of asterisks and where they are.
    // Now we should modify the above code to be universal to detecting "symbols"
    // and have it detect numbers. Then we can capture those numbers maybe and get the gears
    //
    // Alternatively for every asterisk we can search through the part numbers
    // to see if/how many are adjacent. An O(n2) algorithm, but should work.
    //assfor: for (asslist.items) |ass| {
    for (asslist.items, 0..) |ass, index| {
        asslist.items[index].gear_num = 0;
        asslist.items[index].gear_multiply = 1;
        try c.cyan().bold().printOut("\nass: {any}", .{asslist.items[index]});
        pnfor: for (list.items) |pn| {
            //const partNumber = struct { number: u64 = 0, line_index: u64 = 0, slice_index: [2]u64 = .{ 0, 0 }, validated: bool = false };
            if (pn.line_index + 1 < ass.line_index) {
                // part number on an earlier line than ass-1
                continue :pnfor;
            }
            if (pn.line_index > ass.line_index + 1) {
                // part number on a later line; no need to look at rest of pns
                // Not a break because i am printing in a continue statement. Well, maybe.
                //break :pnfor;
                continue :pnfor;
            }
            if (pn.line_index + 1 == ass.line_index or pn.line_index == ass.line_index + 1) {
                // pn is on ass's line +1 or -1!
                if (intersect_a_wider(ass.slice_index, pn.slice_index)) {
                    // We have one!
                    try c.yellow().bold().printOut("adding +-{any}", .{pn.number});
                    asslist.items[index].gear_num += 1;
                    asslist.items[index].gear_multiply *= pn.number;
                }
            }
            if (pn.line_index == ass.line_index) {
                // pn is on ass's line!
                //  PN is on left side of slice                    // PN is on right side of slice only +1s so we don't get overflow
                //if (pn.slice_index[1] + 1 == ass.slice_index[0] or pn.slice_index[0] == ass.slice_index[1] + 1) {
                // Get rid of +1s on the [1] becuase slice indices are stupid
                if (pn.slice_index[1] == ass.slice_index[0] or pn.slice_index[0] == ass.slice_index[1]) {
                    try c.yellow().bold().printOut("adding ={any}", .{pn.number});
                    asslist.items[index].gear_num += 1;
                    asslist.items[index].gear_multiply *= pn.number;
                }
            }
        }
        try c.magenta().printOut("gearnum {d}, gearM {d}", .{ asslist.items[index].gear_num, asslist.items[index].gear_multiply });
    }

    var gear_total: u64 = 0;
    for (asslist.items, 0..) |ass, index| {
        if (asslist.items[index].gear_num != 2) {
            asslist.items[index].gear_multiply = 0;
            asslist.items[index].validated = false;
        } else {
            gear_total += ass.gear_multiply;
            asslist.items[index].validated = true;
        }
    }

    // Print whole thing, with colors!
    var itemsindex: u32 = 0;
    var gearindex: u32 = 0;
    std.debug.print("\n", .{});
    for (schematic, 0..) |line, line_index| {
        for (line, 0..) |char, char_index| {
            var is_good: bool = false;
            var is_gear: bool = false;
            // Check for number
            if (itemsindex < list.items.len) {
                if (line_index == list.items[itemsindex].line_index) {
                    if (char_index >= list.items[itemsindex].slice_index[0]) {
                        if (char_index < list.items[itemsindex].slice_index[1]) {
                            is_good = if (list.items[itemsindex].validated) true else false;
                        }
                        if (char_index == list.items[itemsindex].slice_index[1] - 1) {
                            itemsindex += 1;
                        }
                    }
                }
            }
            // Check for asterisk
            if (gearindex < asslist.items.len) {
                if (line_index == asslist.items[gearindex].line_index) {
                    if (char_index >= asslist.items[gearindex].slice_index[0]) {
                        if (char_index < asslist.items[gearindex].slice_index[1]) {
                            is_gear = if (asslist.items[gearindex].validated) true else false;
                        }
                        if (char_index == asslist.items[gearindex].slice_index[1] - 1) {
                            gearindex += 1;
                        }
                    }
                }
            }
            if (is_good) {
                try c.green().bold().printOut("{c}", .{char});
            } else if (is_gear) {
                try c.red().bold().printOut("{c}", .{char});
            } else {
                try c.white().bold().printOut("{c}", .{char});
            }
        }
        std.debug.print("\n", .{});
        //try stdout.print("\n", .{});
    }

    return .{ total, gear_total };
}

// a is the base thing, b is the symbol touching "around" a
pub fn intersect_a_wider(a: [2]u64, b: [2]u64) bool {
    // if either of a is in between b
    //if ((b[0] + 1 >= a[0] and b[0] <= a[1] + 1) or (b[1] + 1 >= a[0] and b[1] <= a[1] + 1)) {
    // Get rid of + 1s for the [1] because it's a slice index. THis is driving me crazy
    if ((b[0] + 1 >= a[0] and b[0] <= a[1]) or (b[1] >= a[0] and b[1] <= a[1])) {
        return true;
    }
    return false;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    std.debug.print("Hello, {s}!\n", .{"World"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    //const stdout = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout);
    //// Buffered writers are for suckers
    ////const stdout = bw.writer();
    //try stdout.print("Run `zig build test` to run the tests.\n", .{});
    //try bw.flush(); // Don't forget to flush!

    // Arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        std.debug.print("You idiot, you need to give the filename for day 2 as input!\n", .{});
        return error.ExpectedArgument;
    }

    // debugging arguments
    //for (args, 0..) |arg, i| {
    //    if (i == 0) continue;
    //    try stdout.print("arg {}: {s} type: {}\n", .{ i, arg, @TypeOf(arg) });
    //}

    // Part 1
    const infile = args[1];

    ////////////////////////////////////
    // Opening the file
    std.debug.print("infile: {s}\n", .{infile});
    const file = try std.fs.cwd().openFile(infile, .{ .mode = .read_only });
    defer file.close();

    var br = std.io.bufferedReader(file.reader());
    var in_stream = br.reader();

    ////////////////////////////////////
    // Reading the file (part 1)
    //var buf: [1024]u8 = undefined;
    var total: u64 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList([]u8).init(allocator);
    defer list.deinit();

    var c = Chameleon.initRuntime(.{ .allocator = allocator });
    defer c.deinit();
    try c.green().bold().printOut("Hello, world!", .{});

    //readUntilDelimiterOrEofAlloc( allocator, '\n', 1024)

    //while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        ////////////////////////////////////
        // Adding the total

        //const parsed_game = try parse_game(line, limit);
        //total += parsed_game.game_num;
        try list.append(line);
        //std.debug.print("giant list:\n{s}\n", .{list.items});
        total += 1;
    }

    //var rounds = std.mem.splitAny(u8, split.rest(), ";");

    //try stdout.print("total: {d}\n", .{total});

    const realtotal = try find_number(list.items);
    //try stdout.print("\n\ntotal: {d} gear_total: {d}\n", .{ realtotal[0], realtotal[1] });
    try c.red().bold().printOut("\n\ntotal: {d} gear_total: {d}\n", .{ realtotal[0], realtotal[1] });
}
