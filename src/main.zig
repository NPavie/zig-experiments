const std = @import("std");
const unicode = std.unicode;

const tokenizer = @import("tokenizer.zig");

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
    const textString = "Hello, Zig tokenizer Parser!";

    const handler: tokenizer.TokenizerEventsHandler = .{
        .OnText = onText,
    };
    var testing = tokenizer.ZaxTokenizer.init(handler, .{});
    defer testing.deinit();
    try testing.parse(textString[0..]);
}
