const std = @import("std");
const unicode = std.unicode;

const sax = @import("sax.zig");

fn onText(text: []const u21) void {
    for (text) |c| {
        if (c > 0x7F) {
            std.debug.print("Non-ASCII char: U+{X}\n", .{c});
        }
        std.debug.print("{u}", .{c});
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    const textString = "Hello, Zig SAX Parser!";

    const handler: sax.TokenizerEventsHandler = .{
        .OnText = onText,
    };
    var tokenizer = sax.ZaxTokenizer.init(handler, .{});
    defer tokenizer.deinit();
    try tokenizer.parse(textString[0..]);
}
