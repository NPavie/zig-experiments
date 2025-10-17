//! SAX parsing very basic implementation for XML 1.1

const std = @import("std");
const unicode = std.unicode;
const testing = std.testing;

const ENTITIES = std.StaticStringMap(u32).initComptime(.{
    .{ "amp", '&' },
    .{ "gt", '>' },
    .{ "lt", '<' },
    .{ "quot", '"' },
    .{ "apos", "'" },
    .{ "AElig", 198 },
    .{ "Aacute", 193 },
    .{ "Acirc", 194 },
    .{ "Agrave", 192 },
    .{ "Aring", 197 },
    .{ "Atilde", 195 },
    .{ "Auml", 196 },
    .{ "Ccedil", 199 },
    .{ "ETH", 208 },
    .{ "Eacute", 201 },
    .{ "Ecirc", 202 },
    .{ "Egrave", 200 },
    .{ "Euml", 203 },
    .{ "Iacute", 205 },
    .{ "Icirc", 206 },
    .{ "Igrave", 204 },
    .{ "Iuml", 207 },
    .{ "Ntilde", 209 },
    .{ "Oacute", 211 },
    .{ "Ocirc", 212 },
    .{ "Ograve", 210 },
    .{ "Oslash", 216 },
    .{ "Otilde", 213 },
    .{ "Ouml", 214 },
    .{ "THORN", 222 },
    .{ "Uacute", 218 },
    .{ "Ucirc", 219 },
    .{ "Ugrave", 217 },
    .{ "Uuml", 220 },
    .{ "Yacute", 221 },
    .{ "aacute", 225 },
    .{ "acirc", 226 },
    .{ "aelig", 230 },
    .{ "agrave", 224 },
    .{ "aring", 229 },
    .{ "atilde", 227 },
    .{ "auml", 228 },
    .{ "ccedil", 231 },
    .{ "eacute", 233 },
    .{ "ecirc", 234 },
    .{ "egrave", 232 },
    .{ "eth", 240 },
    .{ "euml", 235 },
    .{ "iacute", 237 },
    .{ "icirc", 238 },
    .{ "igrave", 236 },
    .{ "iuml", 239 },
    .{ "ntilde", 241 },
    .{ "oacute", 243 },
    .{ "ocirc", 244 },
    .{ "ograve", 242 },
    .{ "oslash", 248 },
    .{ "otilde", 245 },
    .{ "ouml", 246 },
    .{ "szlig", 223 },
    .{ "thorn", 254 },
    .{ "uacute", 250 },
    .{ "ucirc", 251 },
    .{ "ugrave", 249 },
    .{ "uuml", 252 },
    .{ "yacute", 253 },
    .{ "yuml", 255 },
    .{ "copy", 169 },
    .{ "reg", 174 },
    .{ "nbsp", 160 },
    .{ "iexcl", 161 },
    .{ "cent", 162 },
    .{ "pound", 163 },
    .{ "curren", 164 },
    .{ "yen", 165 },
    .{ "brvbar", 166 },
    .{ "sect", 167 },
    .{ "uml", 168 },
    .{ "ordf", 170 },
    .{ "laquo", 171 },
    .{ "not", 172 },
    .{ "shy", 173 },
    .{ "macr", 175 },
    .{ "deg", 176 },
    .{ "plusmn", 177 },
    .{ "sup1", 185 },
    .{ "sup2", 178 },
    .{ "sup3", 179 },
    .{ "acute", 180 },
    .{ "micro", 181 },
    .{ "para", 182 },
    .{ "middot", 183 },
    .{ "cedil", 184 },
    .{ "ordm", 186 },
    .{ "raquo", 187 },
    .{ "frac14", 188 },
    .{ "frac12", 189 },
    .{ "frac34", 190 },
    .{ "iquest", 191 },
    .{ "times", 215 },
    .{ "divide", 247 },
    .{ "OElig", 338 },
    .{ "oelig", 339 },
    .{ "Scaron", 352 },
    .{ "scaron", 353 },
    .{ "Yuml", 376 },
    .{ "fnof", 402 },
    .{ "circ", 710 },
    .{ "tilde", 732 },
    .{ "Alpha", 913 },
    .{ "Beta", 914 },
    .{ "Gamma", 915 },
    .{ "Delta", 916 },
    .{ "Epsilon", 917 },
    .{ "Zeta", 918 },
    .{ "Eta", 919 },
    .{ "Theta", 920 },
    .{ "Iota", 921 },
    .{ "Kappa", 922 },
    .{ "Lambda", 923 },
    .{ "Mu", 924 },
    .{ "Nu", 925 },
    .{ "Xi", 926 },
    .{ "Omicron", 927 },
    .{ "Pi", 928 },
    .{ "Rho", 929 },
    .{ "Sigma", 931 },
    .{ "Tau", 932 },
    .{ "Upsilon", 933 },
    .{ "Phi", 934 },
    .{ "Chi", 935 },
    .{ "Psi", 936 },
    .{ "Omega", 937 },
    .{ "alpha", 945 },
    .{ "beta", 946 },
    .{ "gamma", 947 },
    .{ "delta", 948 },
    .{ "epsilon", 949 },
    .{ "zeta", 950 },
    .{ "eta", 951 },
    .{ "theta", 952 },
    .{ "iota", 953 },
    .{ "kappa", 954 },
    .{ "lambda", 955 },
    .{ "mu", 956 },
    .{ "nu", 957 },
    .{ "xi", 958 },
    .{ "omicron", 959 },
    .{ "pi", 960 },
    .{ "rho", 961 },
    .{ "sigmaf", 962 },
    .{ "sigma", 963 },
    .{ "tau", 964 },
    .{ "upsilon", 965 },
    .{ "phi", 966 },
    .{ "chi", 967 },
    .{ "psi", 968 },
    .{ "omega", 969 },
    .{ "thetasym", 977 },
    .{ "upsih", 978 },
    .{ "piv", 982 },
    .{ "ensp", 8194 },
    .{ "emsp", 8195 },
    .{ "thinsp", 8201 },
    .{ "zwnj", 8204 },
    .{ "zwj", 8205 },
    .{ "lrm", 8206 },
    .{ "rlm", 8207 },
    .{ "ndash", 8211 },
    .{ "mdash", 8212 },
    .{ "lsquo", 8216 },
    .{ "rsquo", 8217 },
    .{ "sbquo", 8218 },
    .{ "ldquo", 8220 },
    .{ "rdquo", 8221 },
    .{ "bdquo", 8222 },
    .{ "dagger", 8224 },
    .{ "Dagger", 8225 },
    .{ "bull", 8226 },
    .{ "hellip", 8230 },
    .{ "permil", 8240 },
    .{ "prime", 8242 },
    .{ "Prime", 8243 },
    .{ "lsaquo", 8249 },
    .{ "rsaquo", 8250 },
    .{ "oline", 8254 },
    .{ "frasl", 8260 },
    .{ "euro", 8364 },
    .{ "image", 8465 },
    .{ "weierp", 8472 },
    .{ "real", 8476 },
    .{ "trade", 8482 },
    .{ "alefsym", 8501 },
    .{ "larr", 8592 },
    .{ "uarr", 8593 },
    .{ "rarr", 8594 },
    .{ "darr", 8595 },
    .{ "harr", 8596 },
    .{ "crarr", 8629 },
    .{ "lArr", 8656 },
    .{ "uArr", 8657 },
    .{ "rArr", 8658 },
    .{ "dArr", 8659 },
    .{ "hArr", 8660 },
    .{ "forall", 8704 },
    .{ "part", 8706 },
    .{ "exist", 8707 },
    .{ "empty", 8709 },
    .{ "nabla", 8711 },
    .{ "isin", 8712 },
    .{ "notin", 8713 },
    .{ "ni", 8715 },
    .{ "prod", 8719 },
    .{ "sum", 8721 },
    .{ "minus", 8722 },
    .{ "lowast", 8727 },
    .{ "radic", 8730 },
    .{ "prop", 8733 },
    .{ "infin", 8734 },
    .{ "ang", 8736 },
    .{ "and", 8743 },
    .{ "or", 8744 },
    .{ "cap", 8745 },
    .{ "cup", 8746 },
    .{ "int", 8747 },
    .{ "there4", 8756 },
    .{ "sim", 8764 },
    .{ "cong", 8773 },
    .{ "asymp", 8776 },
    .{ "ne", 8800 },
    .{ "equiv", 8801 },
    .{ "le", 8804 },
    .{ "ge", 8805 },
    .{ "sub", 8834 },
    .{ "sup", 8835 },
    .{ "nsub", 8836 },
    .{ "sube", 8838 },
    .{ "supe", 8839 },
    .{ "oplus", 8853 },
    .{ "otimes", 8855 },
    .{ "perp", 8869 },
    .{ "sdot", 8901 },
    .{ "lceil", 8968 },
    .{ "rceil", 8969 },
    .{ "lfloor", 8970 },
    .{ "rfloor", 8971 },
    .{ "lang", 9001 },
    .{ "rang", 9002 },
    .{ "loz", 9674 },
    .{ "spades", 9824 },
    .{ "clubs", 9827 },
    .{ "hearts", 9829 },
    .{ "diams", 9830 },
});

/// Zax options
const ParserOptions = struct {
    /// Strict mode : abort on invalid xml detection
    strict: ?bool = false,
    /// Preserve entities : do not decode entities in the text when raising text events
    preserve_entities: ?bool = false,
    /// Raw string : do not decode utf8 characters
    rawstring: ?bool = false,
};

/// XML Namespace definition
const Namespace = struct {
    prefix: ?std.ArrayList(u8),
    uri: ?std.ArrayList(u8),
};

/// XML Attribute : prefix:name="?value"
const Attribute = struct {
    namespace: ?*Namespace,
    name: std.ArrayList(u8),
    value: std.ArrayList(u8),
};

/// XML Tag
const TagBase = struct {
    namespace: ?*Namespace,
    name: std.ArrayList(u8),
};
const OpeningTag = struct {
    base: TagBase,
    selfClosing: ?bool,
    attributes: ?std.ArrayList(Attribute),
};
const ClosingTag = TagBase;

/// XML Processing Instruction
/// Note that the prolog is considered a special PI
const ProcessingInstruction = struct {
    target: std.ArrayList(u8),
    content: std.ArrayList(u8),
};

/// Doctype declaration of an XML document
const Doctype = struct {
    /// Root element name
    root: std.ArrayList(u8),
    /// Public identifier for public typed DTD (undefined on SYSTEM declaration)
    publicId: ?std.ArrayList(u8),
    /// System identifier (URI or path the dtd file)
    systemId: ?std.ArrayList(u8),
    /// Possible subset of dtd declaration available in doctype
    subset: ?std.ArrayList(u8),
};

/// Slice position within the buffer
const BufferSlice = struct {
    start: usize,
    end: usize,
};

// Parsing xml
// FOr each char in the content
// text
// If text and < we start a tag
// if tag and > we end a tag
//

// Ideas
// For the status evaluation,
// consider buffering until some separator is found (any space or < or > or & or ; ir " or ')
// (opening and closing tag state, opening and closing entity state and spaces for element separations within tag)

const TokenizerData = union(enum) {
    text: std.ArrayList(u8), // default state
    entity: std.ArrayList(u8), // & -> // end =  EntityStarted + ; => go up the state tree
    tag: std.ArrayList(u8), // Text + < // tag analysis buffer
    startTag: OpeningTag, // Tag + (namespace+":")? + name + (S + Attribute)* + >
    attribute: std.ArrayList(u8), // OpeningTag + S + (namespace+":")? + name + "="" + AttributeValue + """
    attributeValue: std.ArrayList(u8), // Attribute + =("|')' + content + ("|')
    doctype: Doctype, // DataTagStarted + "DOCTYPE" + S + RootName + S + ((SYSTEM) | (PUBLIC + S + PublicID)) + S + SystemId + (DoctypeSubset)? + S* + >
    doctypeSubset: std.ArrayList(u8), // (DoctypeStarted | DoctypeSubset) + [ + (DoctypeSubset | content) + ]
    closingTag: ClosingTag, // TagStarted + / + (namespace + ":")? + name + >
    comment: std.ArrayList(u8), // DataTagStarted + '--' + content + -- + >
    processingInstruction: ProcessingInstruction, // TagStarted + ? + target + S + content + ?>
    cdata: std.ArrayList(u8), // <![CDATA[ + content + ]]>
};

const TokenizerStatus = enum {
    text, // parser is handling text data
    entity, // Parser is currently handling entity, should start when & is found and end when ; is found
    tag, // Parser is handling any type of tag and continue until a delimiter is found
    startTag, // Parser was in tag state and found
    endTag,
    attribute,
    attributeValue,
    doctype,
    doctypeSubset,
    comment,
    processingInstruction,
    cdata,
};

const XMLTokenizerError = error{
    XMLInvalidCharacterInTag,
    XMLInvalidCharacterInDoctype,
    MLInvalidDoctypeType,
};

const State = struct {
    content: TokenizerStatus = TokenizerStatus.text,
    line: usize = 0,
    column: usize = 0,
    previous: ?*State = null, // for linked list to previous state
};

fn newState(previous: *State, content: TokenizerData, alloc: std.mem.Allocator) *State {
    return alloc.create(State){
        .previous = previous,
        .content = content,
        .line = previous.line,
        .column = previous.column,
    };
}

fn popState(state: *State, alloc: std.mem.Allocator) *State {
    // retrieve previous state
    const previous = state.previous;
    // clean current state
    switch (state.content) {
        .text => state.content.text.deinit(),
        .entity => state.content.entity.deinit(),
        .tag => state.content.tag.deinit(),
        .startTag => |s| {
            s.base.name.deinit();
            s.attributes.?.deinit();
        },
        .attribute => state.content.attribute.deinit(),
        .attributeValue => state.content.attributeValue.deinit(),
        .doctype => |d| {
            d.publicId.?.deinit();
            d.systemId.?.deinit();
            d.subset.?.deinit();
            d.root.deinit();
        },
        .doctypeSubset => state.content.doctypeSubset.deinit(),
        .closingTag => {},
        .comment => state.content.comment.deinit(),
        .processingInstruction => {},
        .cdata => state.content.cdata.deinit(),
        else => {},
    }
    alloc.destroy(state);
    // return pointer to previous state
    return previous;
}

const Cursor = struct {
    line: usize,
    column: usize,
};

const SelectionRange = struct {
    start: Cursor,
    end: Cursor,
};

/// Structure to hold event handlers pointers for the tokenizer
const EventsHandler = struct {
    // Start the parser
    OnDocumentStart: ?*fn () void = undefined,
    OnDocumentEnd: ?*fn () void = undefined,
    // Handle the opening of a named tag
    OnOpeningTagStart: ?*fn (name: []const u21, prefixEnd: usize) void = undefined,
    // Handle attribute name
    OnAttributeName: ?*fn (name: []const u21, prefixEnd: usize) void = undefined,
    // Handle attribute value
    OnAttributeValueStart: ?*fn (delimiter: u21) void = undefined,
    OnAttributeValueContent: ?*fn (content: []const u21) void = undefined,
    OnAttributeValueEnd: ?*fn () void = undefined,
    // Handle the closing of a named tag (including if it is selfclosing)
    OnOpeningTagEnd: ?*fn (selfclosing: bool) void = undefined,
    // Handle the closing of a named tag
    OnClosingTag: ?*fn (name: []const u21, prefixEnd: u32) void = undefined,
    // Handle doctype main part
    OnDoctype: ?*fn (doctype: *Doctype) void = undefined,
    // Handle doctype subset
    OnDoctypeSubsetStart: ?*fn () void = undefined,
    OnDoctypeSubsetContent: ?*fn (content: []const u21) void = undefined,
    OnDoctypeSubsetEnd: ?*fn () void = undefined,
    // Handle comment
    OnCommentStart: ?*fn () void = undefined,
    OnCommentContent: ?*fn (content: []const u21) void = undefined,
    OnCommentEnd: ?*fn () void = undefined,
    // Handle cdata
    OnCDATAStart: ?*fn () void = undefined,
    OnCDATAContent: ?*fn (content: []const u21) void = undefined,
    OnCDATAEnd: ?*fn () void = undefined,
    // Handle processing instructions
    OnProcessingInstruction: ?*fn (pi: *ProcessingInstruction) void = undefined,
    OnProcessingInstructionStart: ?*fn () void = undefined,
    OnProcessingInstructionContent: ?*fn () void = undefined,
    OnProcessingInstructionEnd: ?*fn () void = undefined,
    // Handle text nodes
    OnText: ?*fn (text: []const u21) void = undefined,
    OnXMLErrors: ?*fn (xmlError: XMLTokenizerError, message: []const u21) void = undefined,
};

fn utf8Size(char: u8) u8 {
    if ((char & 0b1000_0000) == 0) {
        return 1;
    } else if ((char & 0b1110_0000) == 0b1100_0000) {
        return 2;
    } else if ((char & 0b1111_0000) == 0b1110_0000) {
        return 3;
    } else if ((char & 0b1111_1000) == 0b1111_0000) {
        return 4;
    } else {
        return 0;
    }
}

fn isUtf8Part(char: u8) bool {
    return (char & 0b1100_0000) == 0b1000_0000;
}

/// Zax tokenizer to parse xml content with a fixed size buffer
///
/// buffer_size : number of characters utf8 to bufferize
///
/// events : event handlers for the parser
pub fn ZaxTokenizer(buffer_size: comptime_int, events: EventsHandler, options: ParserOptions) type {
    return struct {
        const Self = @This();
        // Empty event handlers with no event handlers
        events: EventsHandler = events,
        options: ParserOptions = options,
        charBuffer: [4]u8 = [_]u8{ 0, 0, 0, 0 },
        charBufferLen: u8 = 0,
        parsedChar: u21 = 0,
        parserBuffer: [buffer_size]u21 = [_]u21{0} ** buffer_size,
        parserBufferLen: usize = 0,
        entityBuffer: [10]u21 = [_]u21{0} ** 10, // entity has max 10 characters
        entityBufferLen: usize = 0,
        /// previous status of the parser to recover from errors
        previousStatus: TokenizerStatus = TokenizerStatus.text,
        /// currente status of the parser
        status: TokenizerStatus = TokenizerStatus.text,
        /// Parsing xml text
        pub fn parse(self: Self, xmlBytes: []u8) !void {
            for (xmlBytes, 0..) |char, index| {
                _ = index;
                if (self.options.rawstring) {
                    self.charToParse = char;
                    self.charIsComplete = true;
                } else if (self.charToParse == 0) {
                    self.charToParse = char;
                    self.remainingCharCode = unicode.utf8ByteSequenceLength(char) - 1;
                    if (self.remainingCharCode == -1) {
                        //raise an utf8 decoding error event
                        if (self.events.OnXMLErrors) |onXMLErrors| {
                            onXMLErrors(&self.state, "Invalid UTF8 character");
                        }
                        self.options.rawstring = true;
                        //fallback to raw ascii parsing or replace the char by U+FFFD
                        //remaining = 0
                        self.remainingCharCode = 0;
                        self.charToParse = 0xFFFD;
                    }
                } else {
                    if (isUtf8Part(char)) {
                        self.charToParse = (self.charToParse << 8) | char;
                        self.remainingCharCode -= 1;
                    } else {
                        //raise an utf8 decoding error event
                        if (self.events.OnXMLErrors) |onXMLErrors| {
                            onXMLErrors(&self.state, "Invalid UTF8 character");
                        }
                        self.options.rawstring = true;
                        //fallback to raw ascii parsing or replace the char by U+FFFD
                        //remaining = 0
                        self.remainingCharCode = 0;
                        self.charToParse = 0xFFFD;
                    }
                }
                if (self.remainingCharCode == 0) {
                    self.charToParse = try unicode.utf8Decode(self.charToParseBuffer[0..self.charToParseBufferLen]);

                    self.charToParse = 0;
                }
            }
        }

        fn parseAsText(self: Self, char: u21) !void {
            if (char == '&') {
                self.entityBuffer[0] = char;
                self.entityBufferLen = 1;
                self.previousStatus = TokenizerStatus.text;
                self.status = TokenizerStatus.entity;
            } else if (char == '<') {
                if (self.parsedBufferLen > 0 and self.events.OnText) |onText| {
                    onText(self.parserBuffer[0..self.parsedBufferLen]);
                }
                self.parserBuffer[0] = char;
                self.parserBufferLen = 1;
                self.previousStatus = TokenizerStatus.text;
                self.status = TokenizerStatus.tag;
            } else {
                if (self.parserBufferLen == buffer_size) {
                    if (self.events.OnText) |onText| {
                        onText(self.parserBuffer[0..self.parsedBufferLen]);
                    }
                    self.parserBufferLen = 0;
                }
                self.parserBuffer[self.parserBufferLen] = char;
                self.parserBufferLen += 1;
            }
        }
        fn parseAsEntity(self: Self, char: u21) !void {
            if (char == ';') {
                if (options.preserve_entities) {}
                self.parserBuffer[self.parserBufferLen] = char;
                self.parserBufferLen += 1;
                if (self.events.OnText) |onText| {
                    onText(self.parserBuffer[0..self.parsedBufferLen]);
                }
                self.parserBufferLen = 0;
                self.previousStatus = TokenizerStatus.entity;
                self.status = TokenizerStatus.text;
            } else {
                if (self.parserBufferLen == buffer_size) {
                    if (self.events.OnText) |onText| {
                        onText(self.parserBuffer[0..self.parsedBufferLen]);
                    }
                    self.parserBufferLen = 0;
                }
                self.parserBuffer[self.parserBufferLen] = char;
                self.parserBufferLen += 1;
            }
        }
        //fn parseAsOpeningTag(self: Self, char: u21) !void {}
        //fn parseAsAttributeName(self: Self, char: u21) !void {}
        //fn parseAsAttributeValue(self: Self, char: u21) !void {}
        //fn parseAsComment(self: Self, char: u21) !void {}
        //fn parseAsPI(self: Self, char: u21) !void {}
        //fn parseAsCDATA(self: Self, char: u21) !void {}
    };
}

test "parser initialization" {}

test "parser pi analysis" {}

test "parser tag analysis" {}

test "parser simple document" {}

test "parser doctype analysis" {}
