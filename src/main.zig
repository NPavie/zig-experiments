const std = @import("std");
const unicode = std.unicode;

const sax = @import("sax.zig");

fn onText(text: []const u21) void {
    std.debug.print("Text: {s}\n", .{text});
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const textString = "Hello, Zig SAX Parser!";
    const handler: sax.EventsHandler = .{
        .OnText = onText,
    };
    var tokenizer = sax.ZaxParser.init(handler, .{});
    try tokenizer.parse(textString);
}
