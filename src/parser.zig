const tokenizer = @import("tokenizer.zig");
const xdm = @import("xdm.zig");
const std = @import("std");

// The parser is an extension of the tokenizer but it checks document wide validity of the input
// whereas the tokenizer emits various tokens as they are recognized

pub const ParserOptions = struct {
    // Add parser specific options here
};

pub const ParserEventsInterface = struct {
    // Define parser specific event callbacks here
    OnDocumentStart_fn: ?fn () void,
    OnDocumentEnd_fn: ?fn () void,
    OnAttribute_fn: ?fn (self: *ParserEventsInterface, attribute: xdm.AttributeNode) void,
    OnElement_fn: ?fn (self: *ParserEventsInterface, element: xdm.ElementNode) void,
    OnNamespace_fn: ?fn (self: *ParserEventsInterface, namespace: xdm.NamespaceNode) void,
    OnProcessingInstruction_fn: ?fn (self: *ParserEventsInterface, pi: xdm.ProcessingInstructionNode) void,
    OnText_fn: ?fn (self: *ParserEventsInterface, text: xdm.TextNode) void,
    OnComment_fn: ?fn (self: *ParserEventsInterface, comment: xdm.CommentNode) void,
};

const tokenizerEventsHandler: tokenizer.TokenizerEventsHandler = .{};

pub const ZaxParser = struct {
    tokenizer: tokenizer.ZaxTokenizer,
    pub fn init(allocator: std.mem.Allocator) ZaxParser {
        _ = allocator;

        return ZaxParser{
            .tokenizer = tokenizer.ZaxTokenizer.init(tokenizerEventsHandler, .{
                .preserve_entities = true,
                .rawstring = false,
                .strict = false,
            }),
        };
    }

    pub fn deinit(self: *ZaxParser) void {
        self.tokenizer.deinit();
    }

    pub fn parse(self: *ZaxParser, input: []const u8) !void {
        try self.tokenizer.parse(input);
    }
};
