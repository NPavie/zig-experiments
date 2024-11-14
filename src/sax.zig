//! SAX parsing very basic implementation for XML 1.1

const std = @import("std");
const unicode = std.unicode;
const testing = std.testing;

// XML 1.1 defined entities
// document = ( prolog element Misc* ) - ( Char* RestrictedChar Char* )
// Char : [#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
// RestrictedChar = [#x1-#x8] | [#xB-#xC] | [#xE-#x1F] | [#x7F-#x84] | [#x86-#x9F]
// Discouraged character = [#x1-#x8], [#xB-#xC], [#xE-#x1F], [#x7F-#x84], [#x86-#x9F], [#xFDD0-#xFDDF],
//                         [#x1FFFE-#x1FFFF], [#x2FFFE-#x2FFFF], [#x3FFFE-#x3FFFF],
//                         [#x4FFFE-#x4FFFF], [#x5FFFE-#x5FFFF], [#x6FFFE-#x6FFFF],
//                         [#x7FFFE-#x7FFFF], [#x8FFFE-#x8FFFF], [#x9FFFE-#x9FFFF],
//                         [#xAFFFE-#xAFFFF], [#xBFFFE-#xBFFFF], [#xCFFFE-#xCFFFF],
//                         [#xDFFFE-#xDFFFF], [#xEFFFE-#xEFFFF], [#xFFFFE-#xFFFFF],
//                         [#x10FFFE-#x10FFFF].
//
// Whitespace (S) = (#x20 | #x9 | #xD | #xA)+
//      Note The presence of #xD in the above production is maintained purely for backward compatibility
//           all #xD characters literally present in an XML document are either removed or replaced by #xA characters before any other processing is done
//
// NameStartChar = ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF]
//                  | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF]
//                  | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
// NameChar = NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
// Name = NameStartChar (NameChar)*
// Names = Name (#x20 Name)*
// NmToken = (NameChar)+
// NmTokens =  Nmtoken (#x20 Nmtoken)*
// EntityValue = '"' ([^%&"] | PEReference | Reference)* '"' | "'" ([^%&'] | PEReference | Reference)* "'"
// AttValue = '"' ([^<&"] | Reference)* '"' | "'" ([^<&'] | Reference)* "'"
// SystemLiteral = ('"' [^"]* '"') | ("'" [^']* "'")
// PubidChar = #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
// PubidLiteral = '"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
// CharData = [^<&]* - ([^<&]* ']]>' [^<&]*)

// Comment = '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'

// PI = '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
// PITarget = Name - (('X' | 'x') ('M' | 'm') ('L' | 'l')) // Xml exists but are reserved

// CDSect =	CDStart CData CDEnd
// CDStart = '<![CDATA['
// CData = (Char* - (Char* ']]>' Char*))
// CDEnd = ']]>'

// prolog = XMLDecl Misc* (doctypedecl Misc*)?
// XMLDecl = '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'
// VersionInfo = S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')
// Eq = S? '=' S?
// VersionNum = '1.1' (for xml 1.1 as all of this is coming from this versoin of spec)
// Misc = Comment | PI | S

// doctypedecl = '<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>'
// DeclSep = PEReference | S
// intSubset = (markupdecl | DeclSep)*
// markupdecl = elementdecl | AttlistDecl | EntityDecl | NotationDecl | PI | Comment

// extSubset = TextDecl? extSubsetDecl
// extSubsetDecl = ( markupdecl | conditionalSect | DeclSep)*

//

// Constraints explicited in specifications :
// - Validity constraint = The Name in the document type declaration must match the element type of the root element.
// - Validity constraint = Parameter-entity replacement text must be properly nested with markup declarations.
// That is to say, if either the first character or the last character of a markup declaration (markupdecl above)
// is contained in the replacement text for a parameter-entity reference,
// both must be contained in the same replacement text.
// - Well-formedness = In the internal DTD subset, parameter-entity references must not occur within markup declarations;
// they may occur where markup declarations can occur.
// (This does not apply to references that occur in external parameter entities or to the external subset.)
// - Well-formedness = The external subset, if any, must match the production for extSubset.
// - Well-formedness = The replacement text of a parameter entity reference in a DeclSep must match the production extSubsetDecl.

const ENTITIES = std.ComptimeStringMap(u8, .{
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

fn unicodeToString(u: u32) ![]const u8 {
    var buffer: [5]u8 = undefined;
    const len = unicode.encodeRune(u, buffer[0..]);
    return buffer[0..len];
}

/// Zax options
const Options = struct {
    /// Strict mode : abort on invalid xml detection
    strict: ?bool = false,
};

/// XML Namespace definition
const Namespace = struct {
    prefix: ?[]u8,
    uri: ?[]u8,
};

/// XML Attribute : prefix:name="?value"
const Attribute = struct { namespace: ?*Namespace, name: []u8, value: ?[]u8 };

/// XML Tag
const TagBase = struct {
    namespace: ?*Namespace,
    name: []u8,
};
const OpeningTag = struct {
    base: TagBase,
    selfClosing: ?bool,
    attributes: ?[]Attribute,
};
const ClosingTag = TagBase;

/// XML Processing Instruction
/// Note that the prolog is considered a special PI
const ProcessingInstruction = struct {
    target: []u8,
    content: []u8,
};

/// Doctype declaration of an XML document
const Doctype = struct {
    /// Root element name
    root: []u8,
    /// Public identifier for public typed DTD (undefined on SYSTEM declaration)
    publicId: ?[]u8,
    /// System identifier (URI or path the dtd file)
    systemId: ?[]u8,
    /// Possible subset of dtd declaration available in doctype
    subset: ?[]u8,
};

// Ideas
// For the status evaluation,
// consider buffering until some separator is found (any space or < or > or & or ; ir " or ')
// (opening and closing tag state, opening and closing entity state and spaces for element separations within tag)

const TokenizerStatus = enum {
    Text, // default state
    Entity, // & -> // end =  EntityStarted + ; => go up the state tree
    Tag, // Text + <
    DataTag, // Tag + !
    OpeningTag, // Tag + (namespace+":")? + name + (S + Attribute)* + >
    Attribute, // OpeningTag + S + (namespace+":")? + name + "="" + AttributeValue + """
    AttributeValue, // Attribute + =("|')' + content + ("|')
    Doctype, // DataTagStarted + "DOCTYPE" + S + RootName + S + ((SYSTEM) | (PUBLIC + S + PublicID)) + S + SystemId + (DoctypeSubset)? + S* + >
    DoctypeSubset, // (DoctypeStarted | DoctypeSubset) + [ + (DoctypeSubset | content) + ]
    ClosingTag, // TagStarted + / + (namespace + ":")? + name + >
    Comment, // DataTagStarted + '--' + content + -- + >
    ProcessInstruction, // TagStarted + ? + target + S + content + ?>
    CData, // <![CDATA[ + content + ]]>
};

const TokenizerData = union(enum) {
    text: std.ArrayList(u8),
    entity: std.ArrayList(u8),
    tag: std.ArrayList(u8),
    dataTag: std.ArrayList(u8),
    namedTag: OpeningTag,
    attribute: Attribute,
    attributeValue: std.ArrayList(u8),
    doctype: Doctype,
    doctypeSubset: std.ArrayList(u8),
    closingTag: ClosingTag,
    comment: std.ArrayList(u8),
    processingInstruction: ProcessingInstruction,
    cdata: std.ArrayList(u8),
};

const State = struct {
    step: TokenizerStatus = TokenizerStatus.Text,
    content: TokenizerData = undefined,
    previous: ?*State = null, // for linked list to previous state
    line: usize = 0,
    column: usize = 0,
    // idea : compute an xpath expression while computing the state
    //xpath: std.ArrayList(u8) = undefined, // XPATH path of currently parsed element
};

/// Structure to hold event handlers pointers
const EventsHandler = struct {
    // Start the parser
    OnStart: ?*fn () void = undefined,
    OnSGMLDeclaration: ?*fn () void = undefined,
    OnDocumentEnd: ?*fn () void = undefined,
    OnOpeningTag: ?*fn (tag: *OpeningTag) void = undefined,
    OnClosingTag: ?*fn (tag: *ClosingTag) void = undefined,
    OnDoctypeStarted: ?*fn () void = undefined,
    OnDoctype: ?*fn (doctype: *Doctype) void = undefined,
    OnDoctypeEnded: ?*fn () void = undefined,
    OnCommentStarted: ?*fn () void = undefined,
    OnComment: ?*fn (text: []const u8) void = undefined,
    OnCommentEnded: ?*fn () void = undefined,
    // Handle cdata
    OnCDATAStart: ?*fn () void = undefined,
    OnCDATA: ?*fn (content: []const u8) void = undefined,
    OnCDATAEnd: ?*fn () void = undefined,
    // Handle processing instructions
    OnProcessingInstruction: ?*fn (pi: *ProcessingInstruction) void = undefined,
    // Handle text nodes
    OnText: ?*fn (text: []const u8) void = undefined,
    OnXMLErrors: ?*fn (state: *State, message: []const u8) void = undefined,
    OnXMLWarnings: ?*fn (state: *State, message: []const u8) void = undefined,
};

pub fn ZaxParser() type {
    // const gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        // Empty event handlers with no event handlers
        events: EventsHandler = .{},
        options: Options = .{ .strict = false },
        namespaces: std.ArrayList(Namespace),
        state: ?*State,
        buffer: std.ArrayList(u8),
        lastOpeningDelimiter: u8 = 0, // basic delimiter (possible value : space, <, &, ", ')

        pub fn init(self: Self, events: EventsHandler, alloc: std.mem.Allocator) Self {
            _ = self;
            return .{
                .allocator = alloc,
                .events = events,
                .namespaces = std.ArrayList(Namespace).init(alloc),
                .buffer = std.ArrayList(u8).init(alloc),
            };
        }

        pub fn deinit(self: Self) void {
            // release all resources
            while (self.state) |currentState| {
                const previous = currentState.previous;
                // clean content and xpath arrays
                currentState.content.?.deinit();
                currentState.xpath.deinit();
                // clean the rest of the state
                self.allocator.destroy(currentState);
                self.state = previous;
            }
            // release all namespaces
            self.namespaces.deinit();
            self.buffer.deinit();
        }

        // Parsing algorithm
        // for each char
        //  add the char to the buffer
        // if char is a delimiter
        //  based on the current state,
        //    process the buffer content
        //    send the event if the state has changed
        //  reset the buffer

        /// Parsing xml text
        pub fn parse(self: Self, xmlBytes: []u8) !void {
            // Algorithm
            // for each char
            // if char is <
            //   if state in [TagStarted,TagWithNamespaceStarted, AttributeStarted,AttributeWithNamespaceStarted => error to report but continue if not strict mode
            //
            if (self.state == null) {
                self.state = self.alloc.create(State);
                if (self.events.OnStart) |onStart| {
                    onStart();
                }
            }
            for (xmlBytes, 0..) |char, index| {
                _ = index;
                // Update line and column
                if (char == '\n') {
                    self.state.line += 1;
                    self.state.column = 0;
                } else {
                    self.state.column += 1;
                }
                var addToBuffer = true;
                // Switch on buffer content
                switch (char) {
                    '<' => {
                        switch (self.state.step) {
                            // treated as text
                            TokenizerStatus.Comment => {},
                            TokenizerStatus.CData => {},
                            //
                            else => {
                                // default : create a new tag state pointer
                                const newState: *State = self.allocator.create(State){
                                    .previous = &(self.state), // point to current state
                                    .step = TokenizerStatus.Tag,
                                    .content = .{
                                        .tag = std.ArrayList(u8).init(self.alloc),
                                    },
                                };
                                addToBuffer = false;
                                // update current state pointer
                                self.state = newState;
                            },
                        }
                    },
                    ' ', '\r', '\n', '\t' => { // TODO : hande all spaces
                        switch (self.state.step) {
                            TokenizerStatus.Tag => {
                                // check buffer content
                                // if buffer starts with !--, its a comment
                                //    - create a comment state, add buffer without the !-- characters
                                // if buffer starts with ![CDATA[, its a cdata
                                // - create a cdata state, add buffer without the ![CDATA[ characters

                            },
                            else => {
                                // add to current content
                            },
                        }
                    },
                    '&' => {
                        switch (self.state.step) {
                            // treated as text
                            TokenizerStatus.Comment => {},
                            TokenizerStatus.CData => {},
                            // error cases : entity already started
                            TokenizerStatus.Entity => {
                                // error : entity already started
                                // if strict mode, report error and abort
                                // else climb up state up to first non EntityStarted state,
                                // while merging content of those state into the found state
                            },
                            // else treated as entity start
                            else => {
                                switch (self.state.step) {
                                    else => {
                                        // default : create a new entity state
                                        const newState: *State = self.alloc.create(State){
                                            .previous = &(self.state),
                                            .step = TokenizerStatus.Entity,
                                            .content = .{
                                                .entity = std.ArrayList(u8).init(self.alloc),
                                            },
                                        };
                                        addToBuffer = false;
                                        self.state = newState;
                                    },
                                }
                            },
                        }
                    },
                    ';' => {
                        switch (self.state.step) {
                            TokenizerStatus.EntityStarted => {
                                if (self.state.content.len > 3 and std.mem.eql(u8, self.state.content.?[0..2], "&#x")) {
                                    // content is alledgedly an hexa code
                                } else if (self.state.content.?[0] == '#') {
                                    // content is alledgedly a decimal code
                                } else if (ENTITIES.has(self.state.content.?)) {
                                    // entity is textual, check in the entities map
                                } else {
                                    // unknown entity, forward entity as-is
                                }
                                addToBuffer = false;
                            },
                            else => {
                                // no changes in state definition
                            },
                        }
                    },
                    '>' => {
                        switch (self.state.step) {
                            // treated as text if current buffer is not
                            TokenizerStatus.Comment => {
                                // if previous buffer is not ending with --
                                // add as comment text
                                // else consider comment as closed
                                // and raise event with comment content
                            },
                            TokenizerStatus.CData => {
                                // if previous buffer is not ending with --
                                // add as comment text
                                // else consider comment as closed
                                // and raise event with comment content
                            },
                            TokenizerStatus.OpeningTag => {
                                // ending current tag
                            },
                            else => {},
                        }
                    },
                    '\n' => {
                        switch (self.state.step) {
                            else => {},
                        }
                    },
                    '/' => {},
                    '[' => {},
                    ']' => {},
                    '?' => {},
                    '!' => {},
                    '-' => {},
                    ':' => {
                        switch (self.state.step) {
                            TokenizerStatus.TagStarted => {
                                // Previous content is a namespace identifier
                                // Check if namespace exists
                                // preregister it in namespace list if not
                                //
                                // keep it as currently parsed namespace
                            },
                            TokenizerStatus.AttributeStarted => {
                                // Previous content is a namespace identifier
                                // Prepare a namespace
                                // Previous content is a namespace identifier
                                // Check if namespace exists
                                // preregister it in namespace list if not
                                //
                                // keep it as currently parsed namespace
                            },
                            else => {},
                        }
                    },
                    else => { // any other characters

                        switch (self.state.step) {
                            else => {},
                        }
                    },
                }
                if (addToBuffer) {
                    self.buffer.append(char);
                }
            }
        }
    };
}

test "parser initialization" {}

test "parser pi analysis" {}

test "parser simple document" {}

test "parser doctype analysis" {}
