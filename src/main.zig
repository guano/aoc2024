const std = @import("std");
const Chameleon = @import("chameleon");

pub fn main() !void {

    ////////////////////////////////////
    // Chameleon comptime demonstration
    comptime var c = Chameleon.initComptime();
    comptime var header = c.underline().bold().italic().blink().createPreset();

    std.debug.print("\t\t  {s}{s}{s}{s}{s}{s}{s}{s}{s}\n\n", .{
        header.green().fmt("C"),
        header.red().fmt("H"),
        header.blue().fmt("A"),
        header.magenta().fmt("M"),
        header.yellow().fmt("E"),
        header.green().fmt("L"),
        header.yellow().fmt("E"),
        header.cyan().fmt("O"),
        header.magenta().fmt("N"),
    });
    std.debug.print("{s} {s} {s} {s} {s} {s}\n{s} {s} {s} {s} {s} {s} {s} {s}\n{s} {s} {s} {s} {s} {s}\n", .{
        c.bold().fmt("bold"),
        c.dim().fmt("dim"),
        c.italic().fmt("italic"),
        c.underline().fmt("underline"),
        c.inverse().fmt("inverse"),
        c.strikethrough().fmt("strikethrough"),
        c.red().fmt("red"),
        c.green().fmt("green"),
        c.yellow().fmt("yellow"),
        c.blue().fmt("blue"),
        c.magenta().fmt("magenta"),
        c.cyan().fmt("cyan"),
        c.white().fmt("white"),
        c.gray().fmt("gray"),
        c.bgRed().fmt("bgRed"),
        c.bgGreen().fmt("bgGreen"),
        c.bgYellow().fmt("bgYellow"),
        c.bgBlue().fmt("bgBlue"),
        c.bgMagenta().fmt("bgMagenta"),
        c.bgCyan().fmt("bgCyan"),
    });

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
        std.debug.print("You idiot, you need to give the filename for the day as input!\n", .{});
        return error.ExpectedArgument;
    }
    const infile = args[1];

    ////////////////////////////////////
    // Opening the file
    std.debug.print("opening file: {s}\n", .{infile});
    const file = try std.fs.cwd().openFile(infile, .{ .mode = .read_only });
    defer file.close();
    var br = std.io.bufferedReader(file.reader());
    var in_stream = br.reader();

    ////////////////////////////////////
    // Allocating an ArrayList for the file contents
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList([]u8).init(allocator);
    defer list.deinit();

    ////////////////////////////////////
    // Chameleon runtime initializing
    var cham = Chameleon.initRuntime(.{ .allocator = allocator });
    defer cham.deinit();
    try cham.green().bold().printErr("Hello, world!\n", .{});

    ////////////////////////////////////
    // Reading the file
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        try list.append(line);
    }
    try cham.red().bold().printErr("File {s} has completed reading: {d} lines\n", .{ infile, list.items.len });

    const day3 = @import("day3.zig");
    try day3.main();
}
