// implementation of XDM 3.1 in zig
// With some additions :
// - TextNode have a "CDATA" flag to distinguish between normal text nodes and CDATA sections
//
// reference : https://www.w3.org/TR/xpath-datamodel-31/
const std = @import("std");

const NodeType = enum {
    document,
    element,
    attribute,
    text,
    namespace,
    processing_instruction,
    comment,

    pub const NodeTypeTable = [@typeInfo(NodeType).Enum.fields.len][:0]const u8{
        "document",
        "element",
        "attribute",
        "text",
        "namespace",
        "processing_instruction",
        "comment",
    };

    pub fn str(self: NodeType) [:0]const u8 {
        return NodeTypeTable[@intFromEnum(self)];
    }
};

// TODO : Implementing data types from https://www.w3.org/TR/xmlschema11-2/#built-in-datatypes

//2.7.2 Predefined Types
// In addition to the 19 types defined in Section 3.2 Primitive datatypesXS2 of [Schema Part 2], the data model defines five additional types: xs:anyAtomicType, xs:untyped, xs:untypedAtomic, xs:dayTimeDuration, and xs:yearMonthDuration. These types are defined in the XML Schema namespace with permission of the XML Schema Working Group; in implementations that support [Schema 1.1 Part 2], the XSD 1.1 definitions of xs:anyAtomicType, xs:dayTimeDuration, and xs:yearMonthDuration supersede the definitions in this specification.

// Type wrappers from the spec
const numeric = union(enum) { integer: i32, decimal: f64, float: f32, double: f64 };

/// Duration value as defined in https://www.w3.org/TR/xmlschema11-2/#duration
const duration = struct { months: i64, decimal: f64 };

const anyAtomicType = union(enum) {
    numeric: numeric,
    string: []u8,
};

const AnyType = enum {
    string,
    boolean,
    decimal,
    float,
    double,
    duration,
    dateTime,
    time,
    date,
    gYearMonth,
    gYear,
    gMonthDay,
    gDay,
    gMonth,
    hexBinary,
    base64Binary,
    anyURI,
    QName,
    NOTATION,
    NMTOKENS,
    IDREFS,
    ENTITIES,
    anyAtomicType,
    dayTimeDuration,
    yearMonthDuration,
    @"error",
    dateTimeStamp,
    untypedAtomic,
    numeric,
};

const NS_XML = "http://www.w3.org/XML/1998/namespace";
const NS_XS = "http://www.w3.org/2001/XMLSchema";
const NS_XSI = "http://www.w3.org/2001/XMLSchema-instance";
const NS_FN = "http://www.w3.org/2005/xpath-functions";

const QName = struct {
    uri: []const u8,
    prefix: []const u8,
    localName: []const u8,

    pub fn equal(self: QName, other: QName) bool {
        return (std.mem.eql(u8, self.namespace, other.namespace) and
            std.mem.eql(u8, self.localName, other.localName));
    }
};

// 6. Nodes

pub const DocumentNode = struct {
    _base_uri: ?[]u8,
    _children: ?[]union(enum) {
        element: *ElementNode,
        processing_instruction: *ProcessingInstructionNode,
        comment: *CommentNode,
        text: *TextNode,
    },
    _unparsed_entities: ?[]u8,
    _document_uri: ?[]u8,
    _string_value: []u8,
    _typed_value: []u8,


    fn attributes(self: *DocumentNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *DocumentNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *DocumentNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *DocumentNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *DocumentNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *DocumentNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *DocumentNode) []*Node {

        _ = self;
    }
    fn nilled(self: *DocumentNode) bool {

        _ = self;
    }
    fn node_kind(self: *DocumentNode) []const u8 {
        _ = self;
        return NodeType.document.str();
    }
    fn node_name(self: *DocumentNode) ?QName {

        _ = self;
    }
    fn parent(self: *DocumentNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *DocumentNode) []u8 {

        _ = self;
    }
    fn type_name(self: *DocumentNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *DocumentNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *DocumentNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *DocumentNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

pub const ElementNode = struct {
    _base_uri: ?[]u8,
    _node_name: QName,
    _parent: ?union(enum) {
        element: *ElementNode,
        document: *DocumentNode,
    },
    _schema_type: []u8,
    _children: []union(enum) {
        element: *ElementNode,
        processing_instruction: *ProcessingInstructionNode,
        comment: *CommentNode,
        text: *TextNode,
    },
    _attributes: ?[]*AttributeNode,
    namespaces: ?[]*NamespaceNode,
    _string_value: []u8,
    _typed_value: []u8,
    _nilled: bool,
    _is_id: bool,
    _is_idrefs: bool,

    fn attributes(self: *ElementNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *ElementNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *ElementNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *ElementNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *ElementNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *ElementNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *ElementNode) []*Node {

        _ = self;
    }
    fn nilled(self: *ElementNode) bool {

        _ = self;
    }
    fn node_kind(self: *ElementNode) []const u8 {
        _ = self;
        return NodeType.element.str();
    }
    fn node_name(self: *ElementNode) ?QName {

        _ = self;
    }
    fn parent(self: *ElementNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *ElementNode) []u8 {

        _ = self;
    }
    fn type_name(self: *ElementNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *ElementNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *ElementNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *ElementNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

pub const AttributeNode = struct {
    _node_name: QName,
    _parent: ?*ElementNode,
    schema_type: []u8,
    _string_value: []u8,
    _typed_value: []u8,
    _is_id: bool,
    _is_idrefs: bool,

    fn attributes(self: *AttributeNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *AttributeNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *AttributeNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *AttributeNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *AttributeNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *AttributeNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *AttributeNode) []*Node {

        _ = self;
    }
    fn nilled(self: *AttributeNode) bool {

        _ = self;
    }
    fn node_kind(self: *AttributeNode) []const u8 {
        _ = self;
        return NodeType.attribute.str();
    }
    fn node_name(self: *AttributeNode) ?QName {

        _ = self;
    }
    fn parent(self: *AttributeNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *AttributeNode) []u8 {

        _ = self;
    }
    fn type_name(self: *AttributeNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *AttributeNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *AttributeNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *AttributeNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

pub const NamespaceNode = struct {
    prefix: ?[]u8,
    uri: []u8,
    _parent: ?Node,

    fn attributes(self: *NamespaceNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *NamespaceNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *NamespaceNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *NamespaceNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *NamespaceNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *NamespaceNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *NamespaceNode) []*Node {

        _ = self;
    }
    fn nilled(self: *NamespaceNode) bool {

        _ = self;
    }
    fn node_kind(self: *NamespaceNode) []const u8 {
        _ = self;
        return NodeType.namespace.str();
    }
    fn node_name(self: *NamespaceNode) ?QName {

        _ = self;
    }
    fn parent(self: *NamespaceNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *NamespaceNode) []u8 {

        _ = self;
    }
    fn type_name(self: *NamespaceNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *NamespaceNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *NamespaceNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NamespaceNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

pub const ProcessingInstructionNode = struct {
    target: []u8,
    content: []u8,
    _base_uri: ?[]u8,
    _parent: ?[]u8,

    fn attributes(self: *ProcessingInstructionNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *ProcessingInstructionNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *ProcessingInstructionNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *ProcessingInstructionNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *ProcessingInstructionNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *ProcessingInstructionNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *ProcessingInstructionNode) []*Node {

        _ = self;
    }
    fn nilled(self: *ProcessingInstructionNode) bool {

        _ = self;
    }
    fn node_kind(self: *ProcessingInstructionNode) []const u8 {
        _ = self;
        return NodeType.processing_instruction.str();
    }
    fn node_name(self: *ProcessingInstructionNode) ?QName {

        _ = self;
    }
    fn parent(self: *ProcessingInstructionNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *ProcessingInstructionNode) []u8 {

        _ = self;
    }
    fn type_name(self: *ProcessingInstructionNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *ProcessingInstructionNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *ProcessingInstructionNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *ProcessingInstructionNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

pub const TextNode = struct {
    content: []u8,
    _parent: ?*Node,
    is_cdata: bool,

    fn attributes(self: *TextNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *TextNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *TextNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *TextNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *TextNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *TextNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *TextNode) []*Node {

        _ = self;
    }
    fn nilled(self: *TextNode) bool {

        _ = self;
    }
    fn node_kind(self: *TextNode) []const u8 {
        _ = self;
        return NodeType.text.str();
    }
    fn node_name(self: *TextNode) ?QName {

        _ = self;
    }
    fn parent(self: *TextNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *TextNode) []u8 {

        _ = self;
    }
    fn type_name(self: *TextNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *TextNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *TextNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *TextNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

pub const CommentNode = struct {
    content: []u8,
    _parent: ?*Node,


    fn attributes(self: *CommentNode) []*AttributeNode {

        _ = self;
    }
    fn base_uri(self: *CommentNode) ?[]u8 {

        _ = self;
    }
    fn children(self: *CommentNode) []*Node {

        _ = self;
    }
    fn document_uri(self: *CommentNode) ?[]u8 {

        _ = self;
    }
    fn is_id(self: *CommentNode) bool {

        _ = self;
    }
    fn is_idrefs(self: *CommentNode) bool {

        _ = self;
    }
    fn namespace_nodes(self: *CommentNode) []*Node {

        _ = self;
    }
    fn nilled(self: *CommentNode) bool {

        _ = self;
    }
    fn node_kind(self: *CommentNode) []const u8 {
        _ = self;
        return NodeType.comment.str();
    }
    fn node_name(self: *CommentNode) ?QName {

        _ = self;
    }
    fn parent(self: *CommentNode) ?*Node {

        _ = self;
    }
    fn string_value(self: *CommentNode) []u8 {

        _ = self;
    }
    fn type_name(self: *CommentNode) ?QName {

        _ = self;
    }
    fn typed_value(self: *CommentNode) []anyAtomicType {

        _ = self;
    }
    fn unparsed_entity_public_id(self: *CommentNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *CommentNode, entityname: []u8) []u8 {

        _ = self;
        _ = entityname;
    }
};

// Tagged union for handling nodes interfaces
pub const Node = union(NodeType) {

    document: DocumentNode,
    element: ElementNode,
    attribute:AttributeNode,
    text:TextNode,
    namespace:NamespaceNode,
    processing_instruction: ProcessingInstructionNode,
    comment: CommentNode,

    /// dm:attributes($n as node()) as attribute()*
    ///
    /// The dm:attributes accessor returns the attributes of a node as a sequence containing zero or more Attribute Nodes. The order of Attribute Nodes is stable but implementation dependent.
    /// It is defined on all seven node kinds.
    pub fn attributes(self: *Node) []*AttributeNode {
        switch (self) {
            inline else => |impl| return impl.attributes(),
        }
    }

    /// dm:base-uri($n as node()) as xs:anyURI?
    ///
    ///The dm:base-uri accessor returns the base URI of a node as a sequence containing zero or one URI reference. For more information about base URIs, see https://www.w3.org/TR/xmlbase/.
    ///It is defined on all seven node kinds
    pub fn base_uri(self: *Node) ?[]u8 {
        switch (self) {
            inline else => |impl| return impl.base_uri(),
        }
    }

    /// TODO : dm:children($n as node()) as node()*
    ///
    /// The dm:children accessor returns the children of a node as a sequence containing zero or more nodes.
    /// It is defined on all seven node kinds.
    pub fn children(self: *Node) []*Node {
        switch (self) {
            inline else => |impl| return impl.children(),
        }
    }

    /// TODO : dm:document-uri($node as node()) as xs:anyURI?
    ///
    /// The dm:document-uri accessor returns the absolute URI of the resource from which the Document Node was constructed, if the absolute URI is available. If there is no URI available, or if it cannot be made absolute when the Document Node is constructed, or if it is used on a node other than a Document Node, the empty sequence is returned.
    /// It is defined on all seven node kinds.
    pub fn document_uri(self: *Node) ?[]u8 {
        switch (self) {
            inline else => |impl| return impl.document_uri(),
        }
    }

    /// TODO : dm:is-id($node as node()) as xs:boolean?
    ///
    /// The dm:is-id accessor returns true if the node is an XML ID. Exactly what constitutes an ID depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
    /// It is defined on all seven node kinds.
    pub fn is_id(self: *Node) bool {
        switch (self) {
            inline else => |impl| return impl.is_id(),
        }
    }

    /// TODO : dm:is-idrefs($node as node()) as xs:boolean?
    ///
    /// The dm:is-idrefs accessor returns true if the node is an XML IDREF or IDREFS. Exactly what constitutes an IDREF or IDREFS depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
    // It is defined on all seven node kinds.
    pub fn is_idrefs(self: *Node) bool {
        switch (self) {
            inline else => |impl| return impl.is_idrefs(),
        }
    }

    /// TODO : dm:namespace-nodes($n as node()) as node()*
    ///
    /// The dm:namespace-nodes accessor returns the dynamic, in-scope namespaces associated with a node as a sequence containing zero or more Namespace Nodes. The order of Namespace Nodes is stable but implementation dependent.
    /// It is defined on all seven node kinds.
    pub fn namespace_nodes(self: *Node) []*Node {
        switch (self) {
            inline else => |impl| return impl.namespace_nodes(),
        }
    }

    /// TODO : dm:nilled($n as node()) as xs:boolean?
    ///
    /// The dm:nilled accessor returns true if the node is "nilled". [Schema Part 1] introduced the nilled mechanism to signal that an element should be accepted as valid when it has no content even when it has a content type which does not require or even necessarily allow empty content.
    /// It is defined on all seven node kinds.
    pub fn nilled(self: *Node) bool {
        switch (self) {
            inline else => |impl| return impl.nilled(),
        }
    }

    /// dm:node-kind($n as node()) as xs:string
    ///
    /// The dm:node-kind accessor returns a string identifying the kind of node. It will be one of the following, depending on the kind of node: “attribute”, “comment”, “document”, “element”, “namespace” “processing-instruction”, or “text”.
    /// It is defined on all seven node kinds.
    pub fn node_kind(self: *Node) []const u8 {
        switch (self) {
            inline else => |impl| return impl.node_kind(),
        }
    }

    /// dm:node-name($n as node()) as xs:QName?
    ///
    /// The dm:node-name accessor returns the name of the node as a sequence of zero or one xs:QNames. Note that the QName value includes an optional prefix as described in 3.3.3 QNames and NOTATIONS.
    /// It is defined on all seven node kinds.
    pub fn node_name(self: *Node) ?QName {
        switch (self) {
            inline else => |impl| return impl.node_name(),
        }
    }

    /// TODO : dm:parent($n as node()) as node()?
    ///
    /// The dm:parent accessor returns the parent of a node as a sequence containing zero or one nodes.
    /// It is defined on all seven node kinds.
    pub fn parent(self: *Node) ?*Node {
        switch (self) {
            inline else => |impl| return impl.parent(),
        }
    }

    /// TODO : dm:string-value($n as node()) as xs:string
    ///
    /// The dm:string-value accessor returns the string value of a node.
    /// It is defined on all seven node kinds.
    pub fn string_value(self: *Node) []u8 {
        switch (self) {
            inline else => |impl| return impl.string_value(),
        }
    }

    /// TODO : dm:type-name($n as node()) as xs:QName?
    ///
    /// The dm:type-name accessor returns the name of the schema type of a node as a sequence of zero or one xs:QNames.
    /// It is defined on all seven node kinds.
    pub fn type_name(self: *Node) ?QName {
        switch (self) {
            inline else => |impl| return impl.type_name(),
        }
    }

    /// TODO : dm:typed-value($n as node()) as xs:anyAtomicType*
    ///
    /// The dm:typed-value accessor returns the typed-value of the node as a sequence of zero or more atomic values.
    /// It is defined on all seven node kinds.
    pub fn typed_value(self: *Node) []anyAtomicType {
        switch (self) {
            inline else => |impl| return impl.typed_value(),
        }
    }

    /// TODO : dm:unparsed-entity-public-id($node as node(), $entityname as xs:string) as xs:string?
    ///
    /// The dm:unparsed-entity-public-id accessor returns the public identifier of an unparsed external entity declared in the specified document.
    /// If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, or if the entity has no public identifier, the empty sequence is returned.
    /// It is defined on all seven node kinds.
    pub fn unparsed_entity_public_id(self: *Node, entityname: []u8) []u8 {
        switch (self) {
            inline else => |impl| return impl.unparsed_entity_public_id(entityname),
        }
    }

    /// TODO : dm:unparsed-entity-system-id($node as node(), $entityname as xs:string) as xs:anyURI?
    /// The dm:unparsed-entity-system-id accessor returns the system identifier of an unparsed external entity declared in the specified document. The value is an absolute URI, and is obtained by resolving the [system identifier] of the unparsed entity information item against the [declaration base URI] of the same item. If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, the empty sequence is returned.
    /// It is defined on all seven node kinds.
    pub fn unparsed_entity_system_id(self: *Node, entityname: []u8) []u8 {
        switch (self) {
            inline else => |impl| return impl.unparsed_entity_system_id(entityname),
        }
    }
};
