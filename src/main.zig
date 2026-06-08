const std = @import("std");
const unicode = std.unicode;

const tokenizer = @import("tokenizer.zig");

// implement interface TokenizerEventsInterface

const MyTokenizerEvents = struct {
    name: []const u8,
    testing: u32 = 342,
    // VTable implementation
    methods: tokenizer.Methods = tokenizer.Methods{
        .onCommentStart = onCommentStart,
        .onCommentContent = onCommentContent,
        .onCommentEnd = onCommentEnd,
        .onText = onText,
        .onDocumentStart = null,
    },

    pub fn events(self: *MyTokenizerEvents) tokenizer.EventsInterface {
        return .{ .ptr = self, .methods = self.methods };
    }

    fn onCommentStart(ptr: *anyopaque) void {
        const _self: *MyTokenizerEvents = @ptrCast(@alignCast(ptr));
        std.debug.print("\nComment ({s}) ", .{_self.name});
        _self.testing += 1;
    }

    fn onCommentContent(ptr: *anyopaque, text: []const u21) void {
        const _self: *MyTokenizerEvents = @ptrCast(@alignCast(ptr));
        _ = _self;

        for (text) |c| {
            std.debug.print("{u}", .{c});
        }
    }

    fn onCommentEnd(ptr: *anyopaque) void {
        const _self: *MyTokenizerEvents = @ptrCast(@alignCast(ptr));
        std.debug.print("\nComment END ({d}) ", .{_self.testing});
        std.debug.print("\n", .{});
    }

    fn onText(ptr: *anyopaque, text: []const u21) void {
        const _self: *MyTokenizerEvents = @ptrCast(@alignCast(ptr));
        _ = _self;

        for (text) |c| {
            if (c > 0x7F) {
                std.debug.print("Non-ASCII char: U+{X}\n", .{c});
            }
            std.debug.print("{u}", .{c});
        }
        //std.debug.print("\n", .{});
    }
};

pub fn main() !void {
    const textString = "Hello, <!-- comment --> Zig tokenizer Parser!";
    // needs to be var, because the ptr in the interface is not const (as to allow mutable states in the event handlers)
    var myImpl = MyTokenizerEvents{
        .name = "TestTokenizer",
    };
    // But the events result can be const, as the ptr is not used to mutate the struct in this example
    const myEvents = myImpl.events();
    var testing = tokenizer.ZaxTokenizer.init(&myEvents, .{});
    defer testing.deinit();
    try testing.parse(textString[0..]);
}
