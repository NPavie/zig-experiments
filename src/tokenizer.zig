//! SAX parsing very basic implementation for XML 1.1

const std = @import("std");
const fs = std.fs;
const unicode = std.unicode;
//const testing = std.testing;

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
pub const TokenizerOptions = struct {
    /// Strict mode : abort on invalid xml detection
    strict: ?bool = false,
    /// Preserve entities : do not decode entities in the text when raising text events
    preserve_entities: ?bool = false,
    /// Raw string : do not decode utf8 characters
    rawstring: ?bool = false,
};

/// XML Namespace definition
pub const Namespace = struct {
    prefix: ?[]u8,
    uri: ?[]u8,
};

/// XML Attribute : prefix:name="?value"
pub const Attribute = struct {
    namespace: ?*Namespace,
    name: []u8,
    delimiter: u8, // ' or "
    value: []u8,
};

/// XML Tag
pub const TagBase = struct {
    namespace: ?*Namespace,
    name: []u8,
};
pub const OpeningTag = struct {
    base: TagBase,
    selfClosing: ?bool,
    attributes: ?std.ArrayList(Attribute),
};
pub const ClosingTag = TagBase;

/// XML Processing Instruction
/// Note that the prolog is considered a special PI
pub const ProcessingInstruction = struct {
    target: []u8,
    content: []u8,
};

/// Doctype declaration of an XML document
pub const Doctype = struct {
    /// Root element name
    root: []u8,
    _type: ?[]u8, // SYSTEM or PUBLIC
    /// Public identifier for public typed DTD (undefined on SYSTEM declaration)
    publicId: ?[]u8,
    /// System identifier (URI or path the dtd file)
    systemId: ?[]u8,
    /// Possible subset of dtd declaration available in doctype
    subset: ?[]u8,
};

const TokenizerStatus = enum {
    /// Document starting
    start,
    /// Parsing text
    text, // parser is handling text data
    /// Parsing entity
    entity, // Parser is currently handling entity, should start when & is found and end when ; is found
    /// Parsing tag (anything starting by '<' )
    tag, // Parser is handling any type of tag and continue until a delimiter is found
    dataTag, // tag state + '!' found in parsed buffer, continue to check if doctype, cdata or comment
    /// Parsing <!DOCTYPE element
    doctype, // tag state + "!DOCTYPE" found in parsed buffer parsing as content until '>' or '[' found
    doctypeRoot, // Parsing doctype root element name
    doctypeType, // Parsing doctype type (SYSTEM or PUBLIC)
    doctypePublicId, // Parsing doctype public identifier
    doctypeSystemId, // Parsing doctype system identifier
    doctypeSubset,
    /// Parsing <![CDATA[ element
    cdata, // tag state + "![CDATA[" found in parsed buffer, back to text when ends with "]]>"
    /// Parsing <!--
    comment, // tag state + "!--" found in parsed buffer, ended by "-->"
    /// Parsing <? element
    processingInstruction, // tag state + '?' found in parsed buffer
    processingInstructionContent, // <?target + space found, now parsing content until '?>'
    /// Parsing </ element
    endTag, // tag state + / found in parsed buffer
    /// Parsing <(prefix:)?name element
    namedTag, // tag state + valid (prefix:)?name found in parsed buffer
    selfClosingNamedTag, // tag state + valid (prefix:)?name found in parsed buffer
    /// after namedtag, parsing attribute=["']
    attribute,
    /// After attribute, parsing text until delimiter
    attributeValue,
    /// End of document
    //
    end,
};

const XMLTokenizerError = error{ XMLInvalidToken, Utf8InvalidStartByte, Utf8DecodeError };

pub const TokenizerState = struct {
    status: TokenizerStatus = TokenizerStatus.start,
    currentLine: usize = 0,
    currentColumn: usize = 0,
};

/// Interface to hold event handlers pointers for the tokenizer
pub const TokenizerEventsInterface = struct {
    // Start the parser
    OnDocumentStart_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    OnDocumentEnd_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle the start of a named tag (return the fullname including prefix if any)
    OnNamedTagStart_fn: ?*const fn (self: *TokenizerEventsInterface, name: []const u21) void,
    /// Handle attribute name
    OnAttributeName_fn: ?*const fn (self: *TokenizerEventsInterface, name: []const u21) void,
    /// Handle attribute value start with " or ' delimiter
    OnAttributeValueStart_fn: ?*const fn (self: *TokenizerEventsInterface, delimiter: u21) void,
    /// Handle attribute value content (can be raised multiple times if entity is found)
    OnAttributeValueContent_fn: ?*const fn (self: *TokenizerEventsInterface, content: []const u21) void,
    /// Handle attribute end (previous delimiter was found)
    OnAttributeValueEnd_fn: ?*const fn (self: *TokenizerEventsInterface, delimiter: u21) void,
    /// Handle the closing of a named tag (including if it is selfclosing or not)
    OnNamedTagEnd_fn: ?*const fn (self: *TokenizerEventsInterface, selfclosing: bool) void,
    /// Handle a closing tag
    OnClosingTag_fn: ?*const fn (self: *TokenizerEventsInterface, name: []const u21) void,
    /// Handle doctype opening found
    OnDoctypeStart_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    OnDoctypeRoot_fn: ?*const fn (self: *TokenizerEventsInterface, root: []const u21) void,
    OnDoctypeType_fn: ?*const fn (self: *TokenizerEventsInterface, systemOrPublic: []const u21) void,
    OnDoctypePublicIdStart_fn: ?*const fn (self: *TokenizerEventsInterface, delimiter: u21) void,
    OnDoctypePublicIdContent_fn: ?*const fn (self: *TokenizerEventsInterface, content: []const u21) void,
    OnDoctypePublicIdEnd_fn: ?*const fn (self: *TokenizerEventsInterface, delimiter: u21) void,
    OnDoctypeSystemIdStart_fn: ?*const fn (self: *TokenizerEventsInterface, delimiter: u21) void,
    OnDoctypeSystemIdContent_fn: ?*const fn (self: *TokenizerEventsInterface, content: []const u21) void,
    OnDoctypeSystemIdEnd_fn: ?*const fn (self: *TokenizerEventsInterface, delimiter: u21) void,
    /// Handle doctype subset start found (character [ found while parsing doctype content )
    OnDoctypeSubsetStart_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle doctype subset content (content within [ and ] in DOCTYPE)
    OnDoctypeSubsetContent_fn: ?*const fn (self: *TokenizerEventsInterface, content: []const u21) void,
    /// Handle doctype subset end
    OnDoctypeSubsetEnd_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle doctype end (> found in doctype or after subset end)
    OnDoctypeEnd_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle comment start found
    OnCommentStart_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle comment content
    OnCommentContent_fn: ?*const fn (self: *TokenizerEventsInterface, content: []const u21) void,
    /// Handle comment end found
    OnCommentEnd_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle cdata start found
    OnCDATAStart_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    // Note : CDATA content is meant to be treated as text content, so it is returned via OnText_fn
    /// Handle cdata end found ]]>
    OnCDATAEnd_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle processing instructions start found (<?)
    OnProcessingInstructionStart_fn: ?*const fn (self: *TokenizerEventsInterface, target: []const u21) void,
    /// Handle processing instruction content
    OnProcessingInstructionContent_fn: ?*const fn (self: *TokenizerEventsInterface, content: []const u21) void,
    /// Handle processing instruction end found (?>)
    OnProcessingInstructionEnd_fn: ?*const fn (
        self: *TokenizerEventsInterface,
    ) void,
    /// Handle text nodes
    OnText_fn: ?*const fn (self: *TokenizerEventsInterface, text: []const u21) void,
    /// Handle XML errors found during parsing
    OnXMLErrors_fn: ?*const fn (self: *TokenizerEventsInterface, previous: TokenizerState, current: TokenizerState, xmlError: XMLTokenizerError, message: []const u8) void,
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

/// Zax tokenizer to parse xml content with a fixed size buffer of 4096 unicode characters (u21)
///
/// The tokenizer raises events on "tokens" and associated data, and raises errors on locally malformed xml structures
/// (this is meant to be used in a SAX or a DOM Parser implementation, that would check for structural issues)
pub const ZaxTokenizer = struct {
    const buffer_size = 4096;
    // Empty event handlers with no event handlers
    events: TokenizerEventsInterface,
    options: TokenizerOptions,
    parsedChar: [4]u8 = [_]u8{0} ** 4,
    parsedCharLen: usize = 0,
    remainingCharCode: i8 = 0,
    parserBuffer: [buffer_size]u21 = [_]u21{0} ** buffer_size,
    parserBufferLen: usize = 0,
    contentStartInBuffer: usize = 0,
    contentEndInBuffer: usize = 0,
    delimiter: u21 = 0, // " or '
    //entityBuffer: [10]u21 = [_]u21{0} ** 10, // entity has max 10 characters
    //entityBufferLen: usize = 0,
    /// previous status of the parser to recover from errors
    previousState: TokenizerState = .{
        .status = TokenizerStatus.start,
        .currentLine = 0,
        .currentColumn = 0,
    },
    /// currente status of the parser
    state: TokenizerState = .{
        .status = TokenizerStatus.start,
        .currentLine = 0,
        .currentColumn = 0,
    },

    // Adding allocator for dynamic allocations within events if needed

    /// Update the current state of the tokenizer
    fn changeState(self: *ZaxTokenizer, newStatus: TokenizerStatus) void {
        self.previousState = .{
            .currentColumn = self.state.currentColumn,
            .currentLine = self.state.currentLine,
            .status = self.state.status,
        };
        self.state.status = newStatus;
    }

    pub fn init(events: TokenizerEventsInterface, options: TokenizerOptions) ZaxTokenizer {
        return ZaxTokenizer{
            .events = events,
            .options = options,
            .parsedChar = [_]u8{0} ** 4,
            .parsedCharLen = 0,
            .remainingCharCode = 0,
            .parserBuffer = [_]u21{0} ** buffer_size,
            .parserBufferLen = 0,
            //.entityBuffer = [_]u21{0} ** 10,
            //.entityBufferLen = 0,
            .previousState = .{
                .status = TokenizerStatus.start,
                .currentLine = 0,
                .currentColumn = 0,
            },
            .state = .{
                .status = TokenizerStatus.start,
                .currentLine = 0,
                .currentColumn = 0,
            },
        };
    }

    /// Parsing xml text
    pub fn parse(self: *ZaxTokenizer, xmlBytes: []const u8) XMLTokenizerError!void {
        for (xmlBytes) |char| {
            if (self.state.status == TokenizerStatus.start) {
                if (self.events.OnDocumentStart_fn) |onDocumentStart_fn| {
                    onDocumentStart_fn(
                        self.events,
                    );
                }
                // Note: should add a "prolog" status
                // To check if <?xml version="1.1"?> is present
                // and if not, fallback to xml 1.0 compliance
                self.changeState(TokenizerStatus.text);
                self.parserBufferLen = 0;
            }
            if (self.options.rawstring.?) {
                self.parsedChar[0] = char;
                self.remainingCharCode = 0;
                self.parserBufferLen = 1;
            } else if (self.parsedCharLen == 0) {
                self.parsedChar[self.parsedCharLen] = char;
                self.parsedCharLen += 1;
                self.remainingCharCode = (unicode.utf8ByteSequenceLength(char) catch 0) - 1;
                if (self.remainingCharCode == -1) {
                    //raise an utf8 decoding error event
                    if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                        onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.Utf8InvalidStartByte, "Invalid UTF8 character");
                    }
                }
            } else {
                if (isUtf8Part(char)) {
                    self.parsedChar[self.parsedCharLen] = char;
                    self.parsedCharLen += 1;
                    self.remainingCharCode -= 1;
                } else {
                    //raise an utf8 decoding error event
                    if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                        onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid UTF8 character");
                    }
                }
            }
            if (self.remainingCharCode <= 0) {
                const unicodeChar = if (self.remainingCharCode < 0) 0xFFFD else unicode.utf8Decode(self.parsedChar[0..self.parsedCharLen]) catch return XMLTokenizerError.Utf8DecodeError;
                if (self.parsedCharLen == 1 and self.parsedChar[0] == '\n') {
                    self.state.currentLine += 1;
                    self.state.currentColumn = 0;
                } else {
                    self.state.currentColumn += 1;
                }
                //std.debug.print("l{d} c{d}\n", .{ self.currentLine, self.currentColumn });
                switch (self.state.status) {
                    .start => {},
                    .text => {
                        try self.parseAsText(unicodeChar);
                    },
                    .entity => {
                        try self.parseAsEntity(unicodeChar);
                    },
                    .tag => {
                        try self.parseAsOpeningTag(unicodeChar);
                    },
                    .dataTag => {
                        try self.parseAsDataTag(unicodeChar);
                    },
                    .doctype => {
                        try self.parseAsDoctype(unicodeChar);
                    },
                    .doctypeRoot => {
                        try self.parseAsDoctypeRoot(unicodeChar);
                    },
                    .doctypeType => {
                        try self.parseAsDoctypeType(unicodeChar);
                    },
                    .doctypePublicId => {
                        try self.parseAsPublicID(unicodeChar);
                    },
                    .doctypeSystemId => {
                        try self.parseAsSystemID(unicodeChar);
                    },
                    .doctypeSubset => {
                        try self.parseAsDoctypeSubset(unicodeChar);
                    },
                    .cdata => {
                        try self.parseAsCDATA(unicodeChar);
                    },
                    .comment => {
                        try self.parseAsComment(unicodeChar);
                    },
                    .processingInstruction => {
                        try self.parseAsPI(unicodeChar, false);
                    },
                    .processingInstructionContent => {
                        try self.parseAsPI(unicodeChar, true);
                    },
                    .selfClosingNamedTag => {
                        try self.parseAsNamedTag(unicodeChar, true);
                    },
                    .endTag => {
                        try self.parseAsEndTag(unicodeChar);
                    },
                    .namedTag => {
                        try self.parseAsNamedTag(unicodeChar, false);
                    },
                    .attribute => {
                        try self.parseAsAttributeName(unicodeChar);
                    },
                    .attributeValue => {
                        try self.parseAsAttributeValue(unicodeChar);
                    },
                    .end => {},
                }
                self.parsedChar = [_]u8{0} ** 4;
                self.parsedCharLen = 0;
            }
        }
    }

    pub fn deinit(self: *ZaxTokenizer) void {
        // Todo : flush rest of buffers to finalise treatment
        if (self.events.OnDocumentEnd_fn) |onDocumentEnd_fn| {
            onDocumentEnd_fn(
                self.events,
            );
        }
        // Buffer is not empty, flush as text
        if (self.parserBufferLen > 0) {
            if (self.events.OnText_fn) |onText_fn| {
                onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
            }
        }
    }

    fn parseAsText(self: *ZaxTokenizer, char: u21) !void {
        if (char == '&') {
            if (self.parserBufferLen > 0) {
                if (self.events.OnText_fn) |onText_fn| {
                    onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                }
            }
            self.parserBuffer[0] = char;
            self.parserBufferLen = 1;
            self.previousState = self.state;
            self.changeState(TokenizerStatus.entity);
        } else if (char == '<') {
            if (self.parserBufferLen > 0) {
                if (self.events.OnText_fn) |onText_fn| {
                    onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                }
            }
            self.parserBuffer[0] = char;
            self.parserBufferLen = 1;
            self.previousState = self.state;
            self.changeState(TokenizerStatus.tag);
        } else {
            if (self.parserBufferLen == buffer_size) {
                if (self.events.OnText_fn) |onText_fn| {
                    onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                }
                self.parserBufferLen = 0;
            }
            self.parserBuffer[self.parserBufferLen] = char;
            self.parserBufferLen += 1;
        }
    }

    /// Parse as entity after '&' found in text or attribute value status (parser should be containing '&' at index 0)
    fn parseAsEntity(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (char == ';' or self.parserBufferLen >= 10) { // End of entity
            // Note : for now the entity is not decoded, just raised as text or attribute value content
            // But i'll add an option later to decode entities if requested
            switch (self.previousState.status) {
                .text => {
                    if (self.events.OnText_fn) |onText_fn| {
                        onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                    }
                    self.parserBufferLen = 0;
                },
                .attributeValue => {
                    if (self.events.OnAttributeValueContent_fn) |OnAttributeValueContent_fn| {
                        OnAttributeValueContent_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                    }
                    self.parserBufferLen = 0;
                },
                else => {
                    if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                        onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Entity found in invalid context_fn");
                    }
                    self.changeState(TokenizerStatus.text);
                    // TODO : raise malformed XML, unauthorized entity in current state
                    if (self.options.strict.?) {
                        return XMLTokenizerError.XMLInvalidToken;
                    }
                },
            }
            // TODO : raise malformed entity warning if entity is more than 10 chars
            self.parserBufferLen = 0;
            self.changeState(self.previousState.status);
            self.previousState.status = TokenizerStatus.entity;
        }
    }

    /// Parse as opening tag after '<' found in text status (parser should be containing '<' at index 0)
    fn parseAsOpeningTag(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (self.parserBufferLen == 2) {
            switch (char) {
                '/' => {
                    // End tag
                    self.changeState(TokenizerStatus.endTag);
                    return;
                },
                '?' => {
                    // Processing instruction opened
                    self.changeState(TokenizerStatus.processingInstruction);
                    return;
                },
                '!' => {
                    // Continue parsing special data tag (doctype, comment or cdata)
                    self.changeState(TokenizerStatus.dataTag);
                    return;
                },
                else => { // Other character than closing, pi or data tag indicator
                    if (!isNameStartChar(char)) {
                        // Invalid character after < (should be /, ?, ! or a name start char)
                        if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                            onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "invalid character found after a '<'");
                        }
                        // continue parsing as text
                        if (self.events.OnText_fn) |onText_fn| {
                            onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                        }
                        self.parserBufferLen = 0;
                        // resuming parsing as text
                        self.changeState(TokenizerStatus.text);
                        return;
                    }
                },
            }
        } else if (isWhitespace(char)) {
            // End of named tag definition, switch to named tag state
            const nameEndIndex = self.parserBufferLen - 1;
            // fin de namedtag, doit vérifier que le contenu est valide, sinon renvoyé un warning ou une erreur
            if (self.events.OnNamedTagStart_fn) |onNamedTagStart_fn| {
                onNamedTagStart_fn(self.events, self.parserBuffer[1..nameEndIndex]);
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.namedTag);
            return;
        } else if (char == '>') {
            // fin de namedtag, doit vérifier que le contenu est valide, sinon renvoyé un warning ou une erreur
            if (self.events.OnNamedTagStart_fn) |onNamedTagStart_fn| {
                onNamedTagStart_fn(self.events, self.events, self.parserBuffer[1 .. self.parserBufferLen - 1]);
            }
            if (self.events.OnNamedTagEnd_fn) |onNamedTagEnd_fn| {
                onNamedTagEnd_fn(self.events, self.events, false);
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.text);
            return;
        } else if (char == '/') {
            if (self.events.OnNamedTagStart_fn) |onNamedTagStart_fn| {
                onNamedTagStart_fn(self.events, self.parserBuffer[1 .. self.parserBufferLen - 1]);
            }
            self.changeState(TokenizerStatus.selfClosingNamedTag);
            // Possible self closing tag, continue parsing to check for '>' character
            return;
        } else if (!isNameChar(char)) {
            // Invalid character after < (should be /, ?, ! or a name start char)
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "invalid character found in tag name");
            }
            // continue parsing as text
            if (self.events.OnText_fn) |onText_fn| {
                onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.text);
            return;
        } // else continue parsing as named tag
    }

    /// parsing <? ... ?> processing instruction
    /// Note that the buffer should contain '<?' at index 0 and 1 when starting this function
    fn parseAsPI(self: *ZaxTokenizer, char: u21, inContent: bool) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (inContent) { // parse as content until '?>' found
            if (compareUnicodeWithString(self.parserBuffer[self.parserBufferLen - 2 .. self.parserBufferLen], "?>")) {
                if (self.events.OnProcessingInstructionContent_fn) |OnProcessingInstructionContent_fn| {
                    OnProcessingInstructionContent_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 2]);
                }
                // end of processing instruction
                if (self.events.OnProcessingInstructionEnd_fn) |onProcessingInstructionEnd_fn| {
                    onProcessingInstructionEnd_fn(
                        self.events,
                    );
                }
                self.parserBufferLen = 0;
                self.changeState(TokenizerStatus.text);
                return;
            }
            return;
        } else if (isWhitespace(char)) {
            if (self.parserBufferLen > 3) { // <?a (at least) in parser
                // target found, raise event
                if (self.events.OnProcessingInstructionStart_fn) |onProcessingInstructionStart_fn| {
                    onProcessingInstructionStart_fn(self.events, self.parserBuffer[2 .. self.parserBufferLen - 1]);
                }
                self.parserBufferLen = 0;
                self.changeState(TokenizerStatus.processingInstructionContent);
                return;
            } else {
                // Invalid PI target name
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid processing instruction target name");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
        } else if (char == '?') {
            if (self.parserBufferLen == 3) { //<??
                // Invalid PI target name
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid processing instruction target name");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
            // Continue parsing possible end of processing instruction
            return;
        } else if (char == '>') {
            // minimum <?x?> in parser
            if (self.parserBufferLen > 4 and compareUnicodeWithString(self.parserBuffer[self.parserBufferLen - 2 .. self.parserBufferLen], "?>")) {
                // end of processing instruction after its target
                if (self.events.OnProcessingInstructionStart_fn) |onProcessingInstructionStart_fn| {
                    onProcessingInstructionStart_fn(self.events, self.parserBuffer[2 .. self.parserBufferLen - 2]);
                }
                if (self.events.OnProcessingInstructionEnd_fn) |onProcessingInstructionEnd_fn| {
                    onProcessingInstructionEnd_fn(
                        self.events,
                    );
                }
                self.parserBufferLen = 0;
                self.changeState(TokenizerStatus.text);
                return;
            }
            return;
        } else if (!isNameChar(char)) {
            // Invalid PI target name
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid processing instruction target name");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
        }
    }

    /// parsing <! starting tag to determine if comment, cdata or doctype
    fn parseAsDataTag(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        // TODO : move the following to parseAsDataTag function
        if (compareUnicodeWithString(self.parserBuffer[0..self.parserBufferLen], "<!--")) {
            // continue parsing as comment
            if (self.events.OnCommentStart_fn) |onCommentStart_fn| {
                onCommentStart_fn(
                    self.events,
                );
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.comment);
            return;
        }
        if (compareUnicodeWithString(self.parserBuffer[0..self.parserBufferLen], "<![CDATA[")) {
            // Parsing as cdata
            if (self.events.OnCDATAStart_fn) |onCDATAStart_fn| {
                onCDATAStart_fn(
                    self.events,
                );
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.cdata);
            return;
        }
        if (compareUnicodeWithString(self.parserBuffer[0..self.parserBufferLen], "<!DOCTYPE")) {
            // Parsing as doctype
            if (self.events.OnDoctypeStart_fn) |onDoctypeStart_fn| {
                onDoctypeStart_fn(
                    self.events,
                );
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.doctype);
            return;
        }
        if (self.parserBufferLen >= 9) { // did not match any valid data tag
            // No valid data tag found
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid data tag found after '<!'");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
            return;
        }
        switch (char) {
            '-', 'C', 'D', 'O', 'T', 'Y', 'P', 'E', 'A' => {
                // continue parsing data tag
                return;
            },
            else => {
                // Invalid character and data tag found
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in starting data tag");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            },
        }
    }

    fn parseAsNamedTag(self: *ZaxTokenizer, char: u21, selfClosing: bool) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (selfClosing) {
            if (char == '>') {
                if (self.events.OnNamedTagEnd_fn) |onNamedTagEnd_fn| {
                    onNamedTagEnd_fn(self.events, true);
                }
                self.parserBufferLen = 0;
                self.changeState(TokenizerStatus.text);
                return;
            } else {
                // Invalid character found after closing tag '/' character
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid self-closing tag syntax");
                }
                // Fallback to non closing tag parsing
                self.changeState(TokenizerStatus.namedTag);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
        } else if (isNameChar(char)) {
            self.contentStartInBuffer = self.parserBufferLen - 1;
            self.changeState(TokenizerStatus.attribute);
            return;
        } else if (isWhitespace(char)) {
            // Continuer parsing
            return;
        } else if (char == '/') {
            // Self closing tag
            self.changeState(TokenizerStatus.selfClosingNamedTag);
            return;
        } else if (char == '>') {
            // End of named tag
            if (self.events.OnNamedTagEnd_fn) |onNamedTagEnd_fn| {
                onNamedTagEnd_fn(self.events, false);
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.text);
            return;
        } else {
            // Invalid character in named tag
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in namedtag");
            }
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
        }
    }

    /// Parsing </NameChar S? > closing tag
    fn parseAsEndTag(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (isNameChar(char)) {
            const previousChar = self.parserBuffer[self.parserBufferLen - 1];
            if (!(previousChar == '/' or isNameChar(previousChar))) {
                // current namechar is not after a namechar or right after the slash, malformed xml here
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in closing tag");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
        } else if (isWhitespace(char) and self.parserBufferLen > 2) { //at least </X in parser
            self.contentEndInBuffer = self.parserBufferLen;
            // If the whitespace follows a namechar or a space, continue parsing
            return;
        } else if (char == '>') {
            // End of closing tag
            if (self.events.OnClosingTag_fn) |onClosingTag_fn| {
                onClosingTag_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.text);
            return;
        } else {
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in closing tag");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
        }
    }

    /// Parsing after <!DOCTYPE declaration
    /// (buffer is empty at start of function)
    fn parseAsDoctype(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        // authorised characters are namestartchar or whitespaces
        if (isNameStartChar(char)) {
            // report a doctype opening, reset buffer, start parsing doctype root element name
            if (self.events.OnDoctypeStart_fn) |onDoctypeStart_fn| {
                onDoctypeStart_fn(
                    self.events,
                );
            }
            self.parserBuffer[0] = char;
            self.parserBufferLen = 1;
            self.changeState(TokenizerStatus.doctypeRoot);
            return;
        } else if (isWhitespace(char)) {
            // continue parsing doctype declaration
            return;
        } else {
            // Invalid character found before doctype root element name
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found before doctype root element name");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
        }
    }

    /// Parse doctype root element (parser should start with the first character of the root)
    fn parseAsDoctypeRoot(self: *ZaxTokenizer, char: u21) !void {
        // Authorised characters are namechar, > and [ and whitespace (last three are endings)
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (isWhitespace(char)) {
            // End of doctype root element name
            if (self.events.OnDoctypeRoot_fn) |onDoctypeRoot_fn| {
                onDoctypeRoot_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            self.parserBufferLen = 0;
            // Switch to doctype type search
            self.changeState(TokenizerStatus.doctypeType);
            return;
        } else if (char == '>') {
            // End of doctype declaration
            if (self.events.OnDoctypeRoot_fn) |onDoctypeRoot_fn| {
                onDoctypeRoot_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            if (self.events.OnDoctypeEnd_fn) |onDoctypeEnd_fn| {
                onDoctypeEnd_fn(
                    self.events,
                );
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.text);
            return;
        } else if (char == '[') {
            // End of root, start of subset detected, switch to doctype subset content parsing
            if (self.events.OnDoctypeRoot_fn) |onDoctypeRoot_fn| {
                onDoctypeRoot_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            if (self.events.OnDoctypeSubsetStart_fn) |onDoctypeSubsetStart_fn| {
                onDoctypeSubsetStart_fn(
                    self.events,
                );
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.doctypeSubset);
            return;
        } else if (!isNameChar(char)) {
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in doctype type declaration");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
        }
    }

    fn parseAsDoctypeType(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        // Characters authorized at this state : SYSTEM PUBLIC > [ and whitespaces
        const authorizedCharacters =
            std.mem.containsAtLeast(u21, .{
                'S',
                'Y',
                'T',
                'E',
                'M',
                'P',
                'U',
                'B',
                'L',
                'I',
                'C',
                0x20, // Whitespaces before type
                0x9,
                0xD,
                0xA,
            }, 1, .{char});
        if (!authorizedCharacters) {
            // Invalid character found in doctype type declaration
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found while parsing doctype type declaration");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
            return;
        } else {
            if (isWhitespace(char)) { // Whitespace found
                if (self.parserBufferLen > 1 and !isWhitespace(self.parserBuffer[self.parserBufferLen - 2])) {
                    // If whitespace is after a character other than whitespace
                    // Invalid doctype declaration on position while checking for type
                    if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                        onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in doctype type declaration");
                    }
                    // Fallback to text parsing
                    self.changeState(TokenizerStatus.text);
                    // TODO : raise malformed XML error
                    if (self.options.strict.?) {
                        return XMLTokenizerError.XMLInvalidToken;
                    }
                    return;
                } else return; // continue parsing
            } else if (char == '[') {
                if (self.parserBufferLen > 1 and !isWhitespace(self.parserBuffer[self.parserBufferLen - 2])) {
                    // If [ is after a character other than whitespace
                    // Invalid doctype declaration on position while checking for type
                    if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                        onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in doctype type declaration");
                    }
                    // Fallback to text parsing
                    self.changeState(TokenizerStatus.text);
                    // TODO : raise malformed XML error
                    if (self.options.strict.?) {
                        return XMLTokenizerError.XMLInvalidToken;
                    }
                    return;
                }
                // else
                // No type to report, reset buffer to 0 and switch to doctype subset state
                if (self.events.OnDoctypeSubsetStart_fn) |OnDoctypeSubsetStart_fn| {
                    OnDoctypeSubsetStart_fn(
                        self.events,
                    );
                }
                self.changeState(TokenizerStatus.doctypeSubset);
                self.parserBufferLen = 0;
                return;
            } else if (self.parserBufferLen >= 6 and compareUnicodeWithString(self.parserBuffer[self.parserBufferLen - 6 .. self.parserBufferLen], "SYSTEM")) {
                // SYSTEM found, switch to system id parsing
                if (self.events.OnDoctypeType_fn) |onDoctypeType_fn| {
                    onDoctypeType_fn(self.events, .{ 'S', 'Y', 'S', 'T', 'E', 'M' });
                }
                self.parserBufferLen = 0;
                self.delimiter = 0;
                self.changeState(TokenizerStatus.doctypeSystemId);
                return;
            } else if (self.parserBufferLen >= 6 and compareUnicodeWithString(self.parserBuffer[self.parserBufferLen - 6 .. self.parserBufferLen], "PUBLIC")) {
                // PUBLIC found, switch to public id parsing
                if (self.events.OnDoctypeType_fn) |onDoctypeType_fn| {
                    onDoctypeType_fn(self.events, .{ 'P', 'U', 'B', 'L', 'I', 'C' });
                }
                self.parserBufferLen = 0;
                self.delimiter = 0;
                self.changeState(TokenizerStatus.doctypePublicId);
                return;
            }
        }
    }

    fn parseAsPublicID(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (self.delimiter == 0) {
            const isAuthorizedChar = isPubIdChar(char) or char == '"';
            if (!isAuthorizedChar) {
                // Invalid character found while parsing public id
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found while parsing public id");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            } else if (char == '"' or char == '\'') {
                self.delimiter = char;
                if (self.events.OnDoctypePublicIdStart_fn) |onDoctypePublicIdStart_fn| {
                    onDoctypePublicIdStart_fn(self.events, char);
                }
                self.parserBufferLen = 0;
                return;
            } else if (isWhitespace(char)) {
                return;
            } else {
                // Invalid character found while parsing public id delimiter
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found while parsing public id delimiter");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
        } else if (char == self.delimiter) {
            // End of public id
            if (self.events.OnDoctypePublicId) |onDoctypePublicId| {
                onDoctypePublicId(self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            if (self.events.OnDoctypePublicIdEnd_fn) |onDoctypePublicIdEnd_fn| {
                onDoctypePublicIdEnd_fn(self.events, char);
            }
            self.parserBufferLen = 0;
            self.delimiter = 0;
            self.changeState(TokenizerStatus.doctypeSystemId);
            return;
        } else if (!isPubIdChar(char)) {
            // Invalid character found while parsing public id delimiter
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found while parsing public id ");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.text);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
            return;
        } // else continue parsing public id
    }

    fn parseAsSystemID(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (self.delimiter == 0) {
            if (char == '"' or char == '\'') {
                self.delimiter = char;
                if (self.events.OnDoctypeSystemIdStart_fn) |onDoctypeSystemIdStart_fn| {
                    onDoctypeSystemIdStart_fn(self.events, char);
                }
                self.parserBufferLen = 0;
                return;
            } else if (isWhitespace(char)) {
                return; // continue parsing
            } else {
                // Invalid character found while parsing system id
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found while parsing system id");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.text);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
        } else if (char == self.delimiter) {
            // End of system id
            if (self.events.OnDoctypeSystemIdContent_fn) |onDoctypeSystemIdContent_fn| {
                onDoctypeSystemIdContent_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            if (self.events.OnDoctypeSystemIdEnd_fn) |onDoctypeSystemIdEnd_fn| {
                onDoctypeSystemIdEnd_fn(self.events, char);
            }
            self.parserBufferLen = 0;
            self.delimiter = 0;
            self.changeState(TokenizerStatus.doctype);
            return;
        }
    }

    fn parseAsDoctypeSubset(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        // TODO : check spec for authorized characters
        if (char == ']') {
            // End of doctype subset
            if (self.events.OnDoctypeSubsetContent_fn) |onDoctypeSubsetContent_fn| {
                onDoctypeSubsetContent_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
            }
            if (self.events.OnDoctypeSubsetEnd_fn) |onDoctypeSubsetEnd_fn| {
                onDoctypeSubsetEnd_fn(
                    self.events,
                );
            }
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.doctype);
            return;
        } else {
            // Continue parsing doctype subset content
            return;
        }
    }

    fn parseAsAttributeName(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (isNameChar(char)) {
            // Continue parsing attribute name
            return;
        } else if (char == '=') {
            // End of attribute name
            if (self.events.OnAttributeName_fn) |onAttributeName_fn| {
                onAttributeName_fn(self.events, self.parserBuffer[self.contentStartInBuffer .. self.parserBufferLen - 1]);
            }
            self.contentStartInBuffer = 0;
            self.parserBufferLen = 0;
            self.changeState(TokenizerStatus.attributeValue);
            return;
        } else {
            // Invalid character found in attribute name
            if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found in attribute name");
            }
            // Fallback to text parsing
            self.changeState(TokenizerStatus.tag);
            // TODO : raise malformed XML error
            if (self.options.strict.?) {
                return XMLTokenizerError.XMLInvalidToken;
            }
        }
    }

    fn parseAsAttributeValue(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (self.delimiter == 0) {
            if (char == '"' or char == '\'') {
                self.delimiter = char;
                if (self.events.OnAttributeValueStart_fn) |onAttributeValueStart_fn| {
                    onAttributeValueStart_fn(self.events, char);
                }
                self.parserBufferLen = 0;
                return;
            } else {
                // Invalid character found while parsing attribute value
                if (self.events.OnXMLErrors_fn) |onXMLErrors_fn| {
                    onXMLErrors_fn(self.events, self.previousState, self.state, XMLTokenizerError.XMLInvalidToken, "Invalid character found while parsing attribute value");
                }
                // Fallback to text parsing
                self.changeState(TokenizerStatus.namedTag);
                // TODO : raise malformed XML error
                if (self.options.strict.?) {
                    return XMLTokenizerError.XMLInvalidToken;
                }
            }
        } else if (char == self.delimiter) {
            // End of attribute value
            if (self.events.OnAttributeValueContent_fn) |onAttributeValueContent_fn| {
                onAttributeValueContent_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
            }
            if (self.events.OnAttributeValueEnd_fn) |onAttributeValueEnd_fn| {
                onAttributeValueEnd_fn(self.events, char);
            }
            self.parserBufferLen = 0;
            self.delimiter = 0;
            self.changeState(TokenizerStatus.namedTag);
            return;
        } else {
            if (char == '&') { // entity check in attribute value
                if (self.parserBufferLen > 0) { // clear buffer before switching state
                    if (self.events.OnAttributeValueContent_fn) |onAttributeValueContent_fn| {
                        onAttributeValueContent_fn(self.events, self.parserBuffer[0 .. self.parserBufferLen - 1]);
                    }
                }
                self.parserBuffer[0] = char;
                self.parserBufferLen = 1;
                self.previousState = self.state;
                self.changeState(TokenizerStatus.entity);
            } else if (self.parserBufferLen == buffer_size) {
                if (self.events.OnAttributeValueContent_fn) |onAttributeValueContent_fn| {
                    onAttributeValueContent_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
                }
                self.parserBufferLen = 0;
            } // else continue parsing
        }
    }

    fn parseAsComment(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        const isOver = self.parserBufferLen >= 3 and
            compareUnicodeWithString(self.parserBuffer[self.parserBufferLen - 3 .. self.parserBufferLen], "-->");
        if (self.parserBufferLen == buffer_size or isOver) {
            if (self.events.OnCommentContent_fn) |onCommentContent_fn| {
                onCommentContent_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
            }
            self.parserBufferLen = 0;
            if (isOver) {
                if (self.events.OnCommentEnd_fn) |onCommentEnd_fn| {
                    onCommentEnd_fn(self.events);
                }
                self.changeState(TokenizerStatus.text);
            }
        }
    }
    fn parseAsCDATA(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        const isOver = self.parserBufferLen >= 3 and
            compareUnicodeWithString(self.parserBuffer[self.parserBufferLen - 3 .. self.parserBufferLen], "]]>");
        if (self.parserBufferLen == buffer_size or isOver) {
            if (self.events.OnText_fn) |onText_fn| {
                onText_fn(self.events, self.parserBuffer[0..self.parserBufferLen]);
            }
            self.parserBufferLen = 0;
            if (isOver) {
                if (self.events.OnCDATAEnd_fn) |onCDATAEnd_fn| {
                    onCDATAEnd_fn(
                        self.events,
                    );
                }
                self.changeState(TokenizerStatus.text);
            }
        }
    }
};

fn compareUnicodeWithString(lhs: []const u21, rhs: []const u8) bool {
    // Both empty
    if (lhs.len == 0 and rhs.len == 0) return true;
    // Different sizes
    if (lhs.len != rhs.len) return false;
    // Char by char check
    for (lhs, 0..) |char, index| {
        if (char != rhs[index]) {
            return false;
        }
    }
    return true;
}

///[#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
fn isChar(char: u21) bool {
    return (char >= 0x1 and char <= 0xD7FF) or
        (char >= 0xE000 and char <= 0xFFFD) or
        (char >= 0x10000 and char <= 0x10FFFF);
}

///[#x1-#x8] | [#xB-#xC] | [#xE-#x1F] | [#x7F-#x84] | [#x86-#x9F]
fn isRestrictedChar(char: u21) bool {
    return (char >= 0x1 and char <= 0x8) or
        (char >= 0xB and char <= 0xC) or
        (char >= 0xE and char <= 0x1F) or
        (char >= 0x7F and char <= 0x84) or
        (char >= 0x86 and char <= 0x9F);
}

fn isWhitespace(char: u21) bool {
    return (char == 0x20 or char == 0x9 or char == 0xD or char == 0xA);
}

fn isNameStartChar(char: u21) bool {
    return char == ':' or
        char == '_' or
        (char >= 'A' and char <= 'Z') or
        (char >= 'a' and char <= 'z') or
        (char >= 0xC0 and char <= 0xD6) or
        (char >= 0xD8 and char <= 0xF6) or
        (char >= 0xF8 and char <= 0x2FF) or
        (char >= 0x370 and char <= 0x37D) or
        (char >= 0x37F and char <= 0x1FFF) or
        (char >= 0x200C and char <= 0x200D) or
        (char >= 0x2070 and char <= 0x218F) or
        (char >= 0x2C00 and char <= 0x2FEF) or
        (char >= 0x3001 and char <= 0xD7FF) or
        (char >= 0xF900 and char <= 0xFDCF) or
        (char >= 0xFDF0 and char <= 0xFFFD) or
        (char >= 0x10000 and char <= 0xEFFFF);
}

fn isNameChar(char: u21) bool {
    return isNameStartChar(char) or char == '-' or char == '.' or
        (char >= '0' and char <= '9') or char == 0xB7 or
        (char >= 0x0300 and char <= 0x036F) or
        (char >= 0x203F and char <= 0x2040);
}

fn isPubIdChar(char: u21) bool {
    // #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
    return char == 0x20 or
        char == 0xD or
        char == 0xA or
        (char >= 'A' and char <= 'Z') or
        (char >= 'a' and char <= 'z') or
        (char >= '0' and char <= '9') or
        char == '-' or
        char == '\'' or
        char == '(' or
        char == ')' or
        char == '+' or
        char == ',' or
        char == '.' or
        char == '/' or
        char == ':' or
        char == '=' or
        char == '?' or
        char == ';' or
        char == '!' or
        char == '*' or
        char == '#' or
        char == '@' or
        char == '$' or
        char == '_' or
        char == '%';
}

test "parseAsText" {
    var tokenizer = ZaxTokenizer.init(.{}, .{});
    try tokenizer.parseAsText('H');
    try tokenizer.parseAsText('e');
    try tokenizer.parseAsText('l');
    try tokenizer.parseAsText('l');
    try tokenizer.parseAsText('o');
    try tokenizer.parseAsText(',');
    try tokenizer.parseAsText(' ');
    try tokenizer.parseAsText('W');
    try tokenizer.parseAsText('o');
    try tokenizer.parseAsText('r');
    try tokenizer.parseAsText('l');
    try tokenizer.parseAsText('d');
    try tokenizer.parseAsText('!');
    std.testing.expect(tokenizer.parserBufferLen == 13);
    std.testing.expect(std.mem.eql(u21, tokenizer.parserBuffer[0..tokenizer.parserBufferLen], "Hello, World!"));
}
