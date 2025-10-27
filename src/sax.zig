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
pub const ParserOptions = struct {
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
    /// Parsing <!DOCTYPE element
    doctype, // tag state + "!DOCTYPE" found in parsed buffer
    /// Parsing <![CDATA[ element
    cdata, // tag state + "![CDATA[" found in parsed buffer, back to text when ends with "]]>"
    /// Parsing <!--
    comment, // tag state + "!--" found in parsed buffer, ended by "-->"
    /// Parsing <? element
    processingInstruction, // tag state + '?' found in parsed buffer
    /// Parsing </ element
    endTag, // tag state + / found in parsed buffer
    /// Parsing <(prefix:)?name element
    namedTag, // tag state + valid (prefix:)?name found in parsed buffer
    /// after namedtag, parsing attribute=["']
    attribute,
    /// After attribute, parsing text until delimiter
    attributeValue,
    /// After
    doctypeSubset,
    /// End of document
    // 
    end,
};

const XMLTokenizerError = error{
    XMLInvalidXML,
    Utf8InvalidStartByte,
    Utf8DecodeError
};


pub const TokenizerState = struct {
    status: TokenizerStatus = TokenizerStatus.start,
    currentLine: usize = 0,
    currentColumn: usize = 0,
};

/// Structure to hold event handlers pointers for the tokenizer
pub const TokenizerEventsHandler = struct {
    // Start the parser
    OnDocumentStart: ?*const fn () void = undefined,
    OnDocumentEnd: ?*const fn () void = undefined,
    // Handle the start of a named tag (return the prefix and name)
    OnNamedTagStart: ?*const fn (name: []const u21) void = undefined,
    // Handle attribute name
    OnAttributeName: ?*const fn (name: []const u21) void = undefined,
    // Handle attribute value
    OnAttributeValueStart: ?*const fn (delimiter: u21) void = undefined,
    OnAttributeValueContent: ?*const fn (content: []const u21) void = undefined,
    OnAttributeValueEnd: ?*const fn () void = undefined,
    // Handle the closing of a named tag (including if it is selfclosing)
    OnOpeningTagEnd: ?*const fn (selfclosing: bool) void = undefined,
    // Handle the closing of a named tag
    OnClosingTag: ?*const fn (name: []const u21, prefixEnd: u32) void = undefined,
    // Handle doctype main part
    OnDoctypeStart: ?*const fn (doctype: Doctype) void = undefined,
    // Handle doctype subset
    OnDoctypeSubsetStart: ?*const fn () void = undefined,
    OnDoctypeSubsetContent: ?*const fn (content: []const u21) void = undefined,
    OnDoctypeSubsetEnd: ?*const fn () void = undefined,
    OnDoctypeEnd: ?*const fn () void = undefined,
    // Handle comment
    OnCommentStart: ?*const fn () void = undefined,
    OnCommentContent: ?*const fn (content: []const u21) void = undefined,
    OnCommentEnd: ?*const fn () void = undefined,
    // Handle cdata
    OnCDATAStart: ?*const fn () void = undefined,
    OnCDATAContent: ?*const fn (content: []const u21) void = undefined,
    OnCDATAEnd: ?*const fn () void = undefined,
    // Handle processing instructions
    OnProcessingInstructionStart: ?*const fn () void = undefined,
    OnProcessingInstructionContent: ?*const fn () void = undefined,
    OnProcessingInstructionEnd: ?*const fn () void = undefined,
    // Handle text nodes
    OnText: ?*const fn (text: []const u21) void = undefined,
    OnXMLErrors: ?*const fn (state: TokenizerState, xmlError: XMLTokenizerError, message: []const u8) void = undefined,
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
pub const ZaxTokenizer = struct {
    const buffer_size = 64 * 4096;
    // Empty event handlers with no event handlers
    events: TokenizerEventsHandler,
    options: ParserOptions,
    parsedChar: [4]u8 = [_]u8{0} ** 4,
    parsedCharLen: usize = 0,
    remainingCharCode: i8 = 0,
    parserBuffer: [buffer_size]u21 = [_]u21{0} ** buffer_size,
    parserBufferLen: usize = 0,
    entityBuffer: [10]u21 = [_]u21{0} ** 10, // entity has max 10 characters
    entityBufferLen: usize = 0,
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
    currentLine: usize = 0,
    currentColumn: usize = 0,

    pub fn init(events: TokenizerEventsHandler, options: ParserOptions) ZaxTokenizer {
        return ZaxTokenizer{
            .events = events,
            .options = options,
            .parsedChar = [_]u8{0} ** 4,
            .parsedCharLen = 0,
            .remainingCharCode = 0,
            .parserBuffer = [_]u21{0} ** buffer_size,
            .parserBufferLen = 0,
            .entityBuffer = [_]u21{0} ** 10,
            .entityBufferLen = 0,
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
            .currentLine = 0,
            .currentColumn = 0,
            //.allocator = allocator,
        };
    }

    /// Parsing xml text
    pub fn parse(self: *ZaxTokenizer, xmlBytes: []const u8) XMLTokenizerError!void  {
        for (xmlBytes) |char| {
            if (self.state.status == TokenizerStatus.start) {
                if (self.events.OnDocumentStart) |onDocumentStart| {
                    onDocumentStart();
                }
                self.state.status = TokenizerStatus.text;
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
                    if (self.events.OnXMLErrors) |onXMLErrors| {
                        onXMLErrors(self.state, XMLTokenizerError.Utf8InvalidStartByte, "Invalid UTF8 character");
                    }
                }
            } else {
                if (isUtf8Part(char)) {
                    self.parsedChar[self.parsedCharLen] = char;
                    self.parsedCharLen += 1;
                    self.remainingCharCode -= 1;
                } else {
                    //raise an utf8 decoding error event
                    if (self.events.OnXMLErrors) |onXMLErrors| {
                        onXMLErrors(self.state, XMLTokenizerError.XMLInvalidXML, "Invalid UTF8 character");
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
                    .doctype => {},
                    .cdata => {},
                    .comment => {},
                    .processingInstruction => {},
                    .endTag => {},
                    .namedTag => {},
                    .attribute => {},
                    .attributeValue => {},
                    .doctypeSubset => {},
                    .end => {},
                }
                self.parsedChar = [_]u8{0} ** 4;
                self.parsedCharLen = 0;
            }
        }
    }

    pub fn deinit(self: *ZaxTokenizer) void {
        // Todo : flush rest of buffers to finalise treatment
        if (self.events.OnDocumentEnd) |onDocumentEnd| {
            onDocumentEnd();
        }
        // Buffer is not empty, flush as text
        if (self.parserBufferLen > 0) {
            if (self.events.OnText) |onText| {
                onText(self.parserBuffer[0..self.parserBufferLen]);
            }
        }
    }

    fn parseAsText(self: *ZaxTokenizer, char: u21) !void {
        if (char == '&') {
            if (self.parserBufferLen > 0) {
                if (self.events.OnText) |onText| {
                    onText(self.parserBuffer[0..self.parserBufferLen]);
                }
            }
            self.parserBuffer[0] = char;
            self.parserBufferLen = 1;
            self.previousState = self.state;
            self.state.status = TokenizerStatus.entity;
        } else if (char == '<') {
            if (self.parserBufferLen > 0) {
                if (self.events.OnText) |onText| {
                    onText(self.parserBuffer[0..self.parserBufferLen]);
                }
            }
            self.parserBuffer[0] = char;
            self.parserBufferLen = 1;
            self.previousState = self.state;
            self.state.status = TokenizerStatus.tag;
        } else {
            if (self.parserBufferLen == buffer_size) {
                if (self.events.OnText) |onText| {
                    onText(self.parserBuffer[0..self.parserBufferLen]);
                }
                self.parserBufferLen = 0;
            }
            self.parserBuffer[self.parserBufferLen] = char;
            self.parserBufferLen += 1;
        }
    }
    fn parseAsEntity(self: *ZaxTokenizer, char: u21) !void {
        if (char == ';' or self.parserBufferLen >= 10) {
            // (sinon a la place de la taille, vérifier si un caractère non authorisé est rencontré)
            //if (self.options.preserve_entities) {}
            self.parserBuffer[self.parserBufferLen] = char;
            self.parserBufferLen += 1;
            switch (self.previousState.status) {
                .text => {
                    if (self.events.OnText) |onText| {
                        onText(self.parserBuffer[0..self.parserBufferLen]);
                    }
                    self.parserBufferLen = 0;
                },
                .attributeValue => {
                    if (self.events.OnAttributeValueContent) |OnAttributeValueContent| {
                        OnAttributeValueContent(self.parserBuffer[0..self.parserBufferLen]);
                    }
                    self.parserBufferLen = 0;
                },
                else => {
                    if (self.events.OnXMLErrors) |onXMLErrors| {
                        onXMLErrors(self.state, XMLTokenizerError.XMLInvalidXML, "Entity found in invalid context");
                    }
                    self.state.status = TokenizerStatus.text;
                    // TODO : raise malformed XML, unauthorized entity in current state
                    if (self.options.strict.?) {
                        return XMLTokenizerError.XMLInvalidXML;
                    }
                },
            }
            // TODO : raise malformed entity warning if entity is more than 10 chars
            self.parserBufferLen = 0;
            self.state.status = self.previousState.status;
            self.previousState.status = TokenizerStatus.entity;
        } else {
            self.parserBuffer[self.parserBufferLen] = char;
            self.parserBufferLen += 1;
        }
    }
    fn parseAsOpeningTag(self: *ZaxTokenizer, char: u21) !void {
        self.parserBuffer[self.parserBufferLen] = char;
        self.parserBufferLen += 1;
        if (self.parserBufferLen == 2) {
            if (char == '/') {
                // Closing tag
                self.state.status = TokenizerStatus.endTag;
                return;
            }
            if (char == '?') {
                // Processing instruction start
                self.state.status = TokenizerStatus.processingInstruction;
                return;
            }
            if(char == '!'){
                // Continue parsing special data tag (doctype, comment or cdata)
                return;
            }
            if(!isNameStartChar(char)){
                if (self.events.OnXMLErrors) |onXMLErrors| {
                    onXMLErrors(self.state, XMLTokenizerError.XMLInvalidXML, "invalid character found after a '<'");
                }
                // continue parsing as text
                if (self.events.OnText) |onText| {
                    onText(self.parserBuffer[0..self.parserBufferLen]);
                }
                self.parserBufferLen = 0;
                self.state.status = TokenizerStatus.text;
                return;
            }
        }
        if(compareUnicodeWithString(self.parserBuffer[0..self.parserBufferLen], "<!--")){
            // continue parsing as comment
            self.state.status = TokenizerStatus.comment;
            return;
        }
        if(compareUnicodeWithString(self.parserBuffer[0..self.parserBufferLen], "<![CDATA[")){
            self.state.status = TokenizerStatus.cdata;
            return;
        }
        if(compareUnicodeWithString(self.parserBuffer[0..self.parserBufferLen], "<!DOCTYPE")){
            self.state.status = TokenizerStatus.cdata;
            return;
        }
        if(char == '>'){
            // fin de namedtag, doit vérifier que le contenu est valide, sinon renvoyé un warning ou une erreur
            if(self.events.OnNamedTagStart)|onNamedTagStart|{
                _ = onNamedTagStart;
            }
            self.state.status = TokenizerStatus.text;
        }
        // Else continue parsing
    }
    //fn parseAsAttributeName(self: Self, char: u21) !void {}
    //fn parseAsAttributeValue(self: Self, char: u21) !void {}
    //fn parseAsComment(self: Self, char: u21) !void {}
    //fn parseAsPI(self: Self, char: u21) !void {}
    //fn parseAsCDATA(self: Self, char: u21) !void {}
};

fn compareUnicodeWithString(lhs: []const u21, rhs: []const u8) bool{
    // Both empty
    if(lhs.len == 0 and rhs.len == 0) return true;
    // Different sizes
    if(lhs.len != rhs.len) return false;
    // Char by char check
    for(lhs, 0..) |char, index| {
        if(char != rhs[index]){
            return false;
        }
    }
    return true;
}

///[#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
fn isXMLChar(char: u21) bool{
    return (char >= 0x1 and char <= 0xD7FF)
        or (char >= 0xE000 and char <= 0xFFFD)
        or (char >= 0x10000 and char <= 0x10FFFF);
}

///[#x1-#x8] | [#xB-#xC] | [#xE-#x1F] | [#x7F-#x84] | [#x86-#x9F]
fn isRestrictedXMLChar(char: u21) bool{
    return (char >= 0x1 and char <= 0x8)
        or (char >= 0xB and char <= 0xC)
        or (char >= 0xE and char <= 0x1F)
        or (char >= 0x7F and char <= 0x84)
        or (char >= 0x86 and char <= 0x9F);
}

fn isWhitespace(char: u21) bool{
    return (char == 0x20 or char == 0x9 or char == 0xD or char == 0xA);
}

fn isNameStartChar(char: u21) bool {
    return char == ':' 
        or (char >= 'A' and char <= 'Z')
        or char == '_'
        or (char >= 'a' and char <= 'z')
        or (char >= 0xC0 and char <= 0xD6)
        or (char >= 0xD8 and char <= 0xF6)
        or (char >= 0xF8 and char <= 0x2FF)
        or (char >= 0x370 and char <= 0x37D)
        or (char >= 0x37F and char <= 0x1FFF) 
        or (char >= 0x200C and char <= 0x200D)
        or (char >= 0x2070 and char <= 0x218F)
        or (char >= 0x2C00 and char <= 0x2FEF)
        or (char >= 0x3001 and char <= 0xD7FF)
        or (char >= 0xF900 and char <= 0xFDCF) 
        or (char >= 0xFDF0 and char <= 0xFFFD)
        or (char >= 0x10000 and char <= 0xEFFFF);
}

fn isNameChar(char: u21) bool {
    return isNameStartChar(char)
        or  char == '-' or char == '.'
        or (char >= '0' and char <= '9')
        or char == 0xB7
        or (char >= 0x0300 and char <= 0x036F) 
        or (char >= 0x203F and char <= 0x2040);
}