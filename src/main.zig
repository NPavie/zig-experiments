const std = @import("std");
const unicode = std.unicode;
const file = std.fs.File;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    try bw.flush();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    var buffer: [4096]u8 = undefined;
    var testFile = std.fs.cwd().openFile(
        "rsrc/test.xml",
        .{ .mode = file.OpenMode.read_only },
    ) catch |err| {
        try stdout.print("could not open file {}", .{
            err,
        });
        try bw.flush();
        return err;
    };

    while (testFile.read(buffer[0..buffer.len])) |read_size| {
        if (read_size > 0) {
            try stdout.print("test reading  = {s}", .{buffer[0..read_size]});
            try bw.flush();
        } else return;
    } else |err| {
        try stdout.print("could not read file {any}", .{
            err,
        });
        try bw.flush();
        return err;
    }
}

pub fn listUnicodeRange(start: u21, end: u21) !void {
    std.debug.print("'", .{});
    for (start..end + 1) |codepoint| {
        const unicodepoint: u21 = @truncate(codepoint);
        //std.debug.print("&#x{X:0>4};", .{unicodepoint});
        std.debug.print("{u}", .{unicodepoint});
    }
    std.debug.print("',\n", .{});
}
pub fn listUnicodeRangeInFile(
    start: u21,
    end: u21,
    output: file,
) !void {
    _ = try output.write("'");
    for (start..end + 1) |codepoint| {
        var code_point_bytes: [4]u8 = undefined;
        const bytes_encoded = try unicode.utf8Encode(@truncate(codepoint), &code_point_bytes);
        _ = try output.write(code_point_bytes[0..bytes_encoded]);
    }
    _ = try output.write("',\n");
}
// ⚡
test "simple test" {
    const testFile: file = try std.fs.cwd().createFile("test.txt", .{});
    // it is a good habit to close a file after you are done with
    // so that other program can read it and prevent data corruption
    // but here we are not yet done writing to the file
    // if only there are a keyword in zig that
    // allow you "defer" code execute to the end of scope...
    defer testFile.close();
    // var code_point_bytes: [4]u8 = undefined;
    // const bytes_encoded = try unicode.utf8Encode(0x26A1, &code_point_bytes);
    // std.debug.print("{d} {s}\n", .{ bytes_encoded, code_point_bytes[0..bytes_encoded] });
    // _ = try testFile.write(code_point_bytes[0..bytes_encoded]);
    // EAST ASIA
    try listUnicodeRangeInFile(0x1100, 0x11FF, testFile);
    try listUnicodeRangeInFile(0x1720, 0x173F, testFile);
    try listUnicodeRangeInFile(0x3040, 0x309F, testFile);
    try listUnicodeRangeInFile(0x30A0, 0x30FF, testFile);
    try listUnicodeRangeInFile(0x3100, 0x312F, testFile);
    try listUnicodeRangeInFile(0x3130, 0x318F, testFile);
    try listUnicodeRangeInFile(0x31A0, 0x31BF, testFile);
    try listUnicodeRangeInFile(0x31F0, 0x31FF, testFile);
    try listUnicodeRangeInFile(0x4DC0, 0x4DFF, testFile);
    try listUnicodeRangeInFile(0x4E00, 0x9FFF, testFile);
    try listUnicodeRangeInFile(0xA000, 0xA48F, testFile);
    try listUnicodeRangeInFile(0xA490, 0xA4CF, testFile);
    try listUnicodeRangeInFile(0xAC00, 0xD7AF, testFile);

    // BIDI
    // try listUnicodeRangeInFile(0x0590, 0x05FF, testFile);
    // try listUnicodeRangeInFile(0x0600, 0x06FF, testFile);
    // try listUnicodeRangeInFile(0x0700, 0x074F, testFile);
    // try listUnicodeRangeInFile(0x0780, 0x07BF, testFile);
    // try listUnicodeRangeInFile(0x0980, 0x09FF, testFile);
    // try listUnicodeRangeInFile(0x0900, 0x097F, testFile);
    // try listUnicodeRangeInFile(0x0A00, 0x0A7F, testFile);
    // try listUnicodeRangeInFile(0x0A80, 0x0AFF, testFile);
    // try listUnicodeRangeInFile(0x0B00, 0x0B7F, testFile);
    // try listUnicodeRangeInFile(0x0B80, 0x0BFF, testFile);
    // try listUnicodeRangeInFile(0x0C00, 0x0C7F, testFile);
    // try listUnicodeRangeInFile(0x0C80, 0x0CFF, testFile);
    // try listUnicodeRangeInFile(0x0D00, 0x0D7F, testFile);
    // try listUnicodeRangeInFile(0x0D80, 0x0DFF, testFile);
    // try listUnicodeRangeInFile(0x0E00, 0x0E7F, testFile);
    // try listUnicodeRangeInFile(0x0E80, 0x0EFF, testFile);
    // try listUnicodeRangeInFile(0x0F00, 0x0FFF, testFile);
    // try listUnicodeRangeInFile(0x1000, 0x109F, testFile);
    // try listUnicodeRangeInFile(0x10A0, 0x10FF, testFile);
    // try listUnicodeRangeInFile(0xFB50, 0xFDFF, testFile);
    // try listUnicodeRangeInFile(0xFE70, 0xFEFF, testFile);

    std.debug.print("\n", .{});
}
