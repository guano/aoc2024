// --- Day 7: Bridge Repair ---

const std = @import("std");
const Chameleon = @import("chameleon");

const Equation = struct { result: u64, operands: std.ArrayList(u64) };


fn get_equation(line: []const u8, equation: *Equation, cham: *Chameleon.RuntimeChameleon) !void {
    // Get the result
    var l = std.mem.splitAny(u8, line, ":");
    const result_s = l.next().?;
    const result: u64 = std.fmt.parseInt(u64, result_s, 0) catch 0;

    try cham.green().printOut("{d} ", .{result});

    // Get the operands
    const operands = l.next().?;
    var r = std.mem.splitAny(u8, operands, " ");
    while (r.next()) |operand_s| {
        if (operand_s.len == 0)
            continue;

        const operand: u64 = std.fmt.parseInt(u64, operand_s, 0) catch 0;

        try cham.cyan().printOut("{d} ", .{operand});

        try equation.operands.append(operand);
    }
    try cham.cyan().printOut("\n", .{});

    equation.result = result;
}

fn equations_deinit(equations: *std.ArrayList(Equation)) void {
    //fn equations_deinit(equations: *std.ArrayList(Equation), cham: *Chameleon.RuntimeChameleon) void {
    //cham.green().bold().printOut("deiniting the equations {any}\n", .{equations}) catch unreachable;
    for (equations.items) | equation | {
        //cham.yellow().bold().printOut("deiniting {any}\n", .{equation.operands}) catch unreachable;
        equation.operands.deinit();
    }
    //cham.cyan().bold().printOut("deiniting equations {any}\n", .{equations}) catch unreachable;
    equations.deinit();
}

fn concat_digits(x: u64, y: u64) u64 {
    var buf: [50]u8 = undefined;
    const doubleformat = std.fmt.bufPrint(&buf, "{d}{d}", .{x, y}) catch unreachable;
    const backtonum = std.fmt.parseInt(u64, doubleformat, 0) catch unreachable;
    return backtonum;
}

fn is_match(result: u64, math: u64) u64 {
    if (result == math) {
        return 1;
    } else {
        return 0;
    }
}

// There's some optimization possible. ex- if the running_total > result
// Without optimization: 38seconds
fn get_matches(result: u64, running_total: u64, rest: []u64) u64 {
    // Single optimization: 23seconds
    if (running_total > result) {
        return 0;
    }

    const plus = running_total + rest[0];
    const mult = running_total * rest[0];
    const conc = concat_digits(running_total, rest[0]);
    if (rest.len == 1) {
        // We've already operated on the last number.
        return is_match(result, plus) + is_match(result, mult) + is_match(result, conc);
    } else {
        // Need to recurse but we've used up one number
        return get_matches(result, plus, rest[1..]) + get_matches(result, mult, rest[1..]) + get_matches(result, conc, rest[1..]);
    }
}

pub fn day7(allocator: std.mem.Allocator, file: *std.ArrayList([]u8), cham: *Chameleon.RuntimeChameleon) !void {
    const file_contents = file.items;

    var equations = std.ArrayList(Equation).init(allocator);
    defer equations_deinit(&equations);

    for (file_contents) |line| {
        try cham.yellow().printOut("{s}\n", .{line});

        const operands = std.ArrayList(u64).init(allocator); // deinit up above
        var equation = Equation{ .result = 0, .operands = operands};
        //cham.bgMagenta().bold().printOut("equation: {}\n operands: {}", .{equation, operands}) catch unreachable;
        //std.debug.print("equation: {}\n operands: {}", .{&equation, &operands});
        try get_equation(line, &equation, cham);

        try equations.append(equation);
    }

    var total_matches: u64 = 0;
    for (equations.items) |equation| {
        const num_matches = get_matches(equation.result, 0, equation.operands.items);
        try cham.magenta().bold().printOut("num_matches: {d} for equation {d}, {any}\n", .{num_matches, equation.result, equation.operands.items});

        // part 1: add up the results from the equations that have any matches
        total_matches += if (num_matches != 0) equation.result else 0;
    }

    try cham.yellow().bold().printOut("\nTotal_matches:: {d}\n", .{total_matches});

    const concat = concat_digits(123456, 789101112);
    try cham.red().bold().printOut("concat digits test: {any} {d}, len {d}\n", .{concat, concat, 0});
}

