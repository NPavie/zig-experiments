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

    node: NodeInterface,

    pub fn init() DocumentNode {
        return .{ .node = NodeInterface{
            .attributes = attributes,
            .base_uri = base_uri,
            .children = children,
            .document_uri = document_uri,
            .is_id = is_id,
            .is_idrefs = is_idrefs,
            .namespace_nodes = namespace_nodes,
            .nilled = nilled,
            .node_kind = node_kind,
            .node_name = node_name,
            .parent = parent,
            .string_value = string_value,
            .type_name = type_name,
            .typed_value = typed_value,
            .unparsed_entity_public_id = unparsed_entity_public_id,
            .unparsed_entity_system_id = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.document.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *DocumentNode = @fieldParentPtr("node", self);
        _ = _self;
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

    node: NodeInterface,

    pub fn init() ElementNode {
        return .{ .node = NodeInterface{
            .attributes = attributes,
            .base_uri = base_uri,
            .children = children,
            .document_uri = document_uri,
            .is_id = is_id,
            .is_idrefs = is_idrefs,
            .namespace_nodes = namespace_nodes,
            .nilled = nilled,
            .node_kind = node_kind,
            .node_name = node_name,
            .parent = parent,
            .string_value = string_value,
            .type_name = type_name,
            .typed_value = typed_value,
            .unparsed_entity_public_id = unparsed_entity_public_id,
            .unparsed_entity_system_id = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.element.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *ElementNode = @fieldParentPtr("node", self);
        _ = _self;
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

    node: NodeInterface,

    pub fn init() AttributeNode {
        return .{ .node = NodeInterface{
            .attributes = attributes,
            .base_uri = base_uri,
            .children = children,
            .document_uri = document_uri,
            .is_id = is_id,
            .is_idrefs = is_idrefs,
            .namespace_nodes = namespace_nodes,
            .nilled = nilled,
            .node_kind = node_kind,
            .node_name = node_name,
            .parent = parent,
            .string_value = string_value,
            .type_name = type_name,
            .typed_value = typed_value,
            .unparsed_entity_public_id = unparsed_entity_public_id,
            .unparsed_entity_system_id = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.attribute.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *AttributeNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
};

pub const NamespaceNode = struct {
    prefix: ?[]u8,
    uri: []u8,
    _parent: ?NodeInterface,

    node: NodeInterface,

    pub fn init() NamespaceNode {
        return .{ .node = NodeInterface{
            .attributes_fn = attributes,
            .base_uri_fn = base_uri,
            .children_fn = children,
            .document_uri_fn = document_uri,
            .is_id_fn = is_id,
            .is_idrefs_fn = is_idrefs,
            .namespace_nodes_fn = namespace_nodes,
            .nilled_fn = nilled,
            .node_kind_fn = node_kind,
            .node_name_fn = node_name,
            .parent_fn = parent,
            .string_value_fn = string_value,
            .type_name_fn = type_name,
            .typed_value_fn = typed_value,
            .unparsed_entity_public_id_fn = unparsed_entity_public_id,
            .unparsed_entity_system_id_fn = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.namespace.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *NamespaceNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
};

pub const ProcessingInstructionNode = struct {
    target: []u8,
    content: []u8,
    _base_uri: ?[]u8,
    _parent: ?[]u8,

    node: NodeInterface,

    pub fn init() ProcessingInstructionNode {
        return .{ .node = NodeInterface{
            .attributes_fn = attributes,
            .base_uri_fn = base_uri,
            .children_fn = children,
            .document_uri_fn = document_uri,
            .is_id_fn = is_id,
            .is_idrefs_fn = is_idrefs,
            .namespace_nodes_fn = namespace_nodes,
            .nilled_fn = nilled,
            .node_kind_fn = node_kind,
            .node_name_fn = node_name,
            .parent_fn = parent,
            .string_value_fn = string_value,
            .type_name_fn = type_name,
            .typed_value_fn = typed_value,
            .unparsed_entity_public_id_fn = unparsed_entity_public_id,
            .unparsed_entity_system_id_fn = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.processing_instruction.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *ProcessingInstructionNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
};

pub const TextNode = struct {
    content: []u8,
    _parent: ?*NodeInterface,
    is_cdata: bool,
    node: NodeInterface,

    pub fn init() TextNode {
        return .{ .node = NodeInterface{
            .attributes_fn = attributes,
            .base_uri_fn = base_uri,
            .children_fn = children,
            .document_uri_fn = document_uri,
            .is_id_fn = is_id,
            .is_idrefs_fn = is_idrefs,
            .namespace_nodes_fn = namespace_nodes,
            .nilled_fn = nilled,
            .node_kind_fn = node_kind,
            .node_name_fn = node_name,
            .parent_fn = parent,
            .string_value_fn = string_value,
            .type_name_fn = type_name,
            .typed_value_fn = typed_value,
            .unparsed_entity_public_id_fn = unparsed_entity_public_id,
            .unparsed_entity_system_id_fn = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.text.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *TextNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
};

pub const CommentNode = struct {
    content: []u8,
    _parent: ?*NodeInterface,

    node: NodeInterface,

    pub fn init() CommentNode {
        return .{ .node = NodeInterface{
            .attributes_fn = attributes,
            .base_uri_fn = base_uri,
            .children_fn = children,
            .document_uri_fn = document_uri,
            .is_id_fn = is_id,
            .is_idrefs_fn = is_idrefs,
            .namespace_nodes_fn = namespace_nodes,
            .nilled_fn = nilled,
            .node_kind_fn = node_kind,
            .node_name_fn = node_name,
            .parent_fn = parent,
            .string_value_fn = string_value,
            .type_name_fn = type_name,
            .typed_value_fn = typed_value,
            .unparsed_entity_public_id_fn = unparsed_entity_public_id,
            .unparsed_entity_system_id_fn = unparsed_entity_system_id,
        } };
    }

    fn attributes(self: *NodeInterface) []*AttributeNode {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn base_uri(self: *NodeInterface) ?[]u8 {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn children(self: *NodeInterface) []*NodeInterface {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn document_uri(self: *NodeInterface) ?[]u8 {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_id(self: *NodeInterface) bool {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn is_idrefs(self: *NodeInterface) bool {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn nilled(self: *NodeInterface) bool {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn node_kind(self: *NodeInterface) []const u8 {
        _ = self;
        return NodeType.comment.str();
    }
    fn node_name(self: *NodeInterface) ?QName {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn parent(self: *NodeInterface) ?*NodeInterface {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn string_value(self: *NodeInterface) []u8 {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn type_name(self: *NodeInterface) ?QName {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn typed_value(self: *NodeInterface) []anyAtomicType {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
    }
    fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
    fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        const _self: *CommentNode = @fieldParentPtr("node", self);
        _ = _self;
        _ = entityname;
    }
};

pub const NodeInterface = struct {
    attributes_fn: *const fn (self: *NodeInterface) []*AttributeNode,
    base_uri_fn: *const fn (self: *NodeInterface) ?[]u8,
    children_fn: *const fn (self: *NodeInterface) []*NodeInterface,
    document_uri_fn: *const fn (self: *NodeInterface) ?[]u8,
    is_id_fn: *const fn (self: *NodeInterface) bool,
    is_idrefs_fn: *const fn (self: *NodeInterface) bool,
    namespace_nodes_fn: *const fn (self: *NodeInterface) []*NodeInterface,
    nilled_fn: *const fn (self: *NodeInterface) bool,
    node_kind_fn: *const fn (self: *NodeInterface) []const u8,
    node_name_fn: *const fn (self: *NodeInterface) ?QName,
    parent_fn: *const fn (self: *NodeInterface) ?*NodeInterface,
    string_value_fn: *const fn (self: *NodeInterface) []u8,
    type_name_fn: *const fn (self: *NodeInterface) ?QName,
    typed_value_fn: *const fn (self: *NodeInterface) []anyAtomicType,
    unparsed_entity_public_id_fn: *const fn (self: *NodeInterface, entityname: []u8) []u8,
    unparsed_entity_system_id_fn: *const fn (self: *NodeInterface, entityname: []u8) []u8,

    /// dm:attributes($n as node()) as attribute()*
    ///
    /// The dm:attributes accessor returns the attributes of a node as a sequence containing zero or more Attribute Nodes. The order of Attribute Nodes is stable but implementation dependent.
    /// It is defined on all seven node kinds.
    pub fn attributes(self: *NodeInterface) []*AttributeNode {
        return self.attributes_fn(self);
    }

    /// dm:base-uri($n as node()) as xs:anyURI?
    ///
    ///The dm:base-uri accessor returns the base URI of a node as a sequence containing zero or one URI reference. For more information about base URIs, see https://www.w3.org/TR/xmlbase/.
    ///It is defined on all seven node kinds
    pub fn base_uri(self: *NodeInterface) ?[]u8 {
        return self.base_uri_fn(self);
    }

    /// TODO : dm:children($n as node()) as node()*
    ///
    /// The dm:children accessor returns the children of a node as a sequence containing zero or more nodes.
    /// It is defined on all seven node kinds.
    pub fn children(self: *NodeInterface) []*NodeInterface {
        return self.children_fn(self);
    }

    /// TODO : dm:document-uri($node as node()) as xs:anyURI?
    ///
    /// The dm:document-uri accessor returns the absolute URI of the resource from which the Document Node was constructed, if the absolute URI is available. If there is no URI available, or if it cannot be made absolute when the Document Node is constructed, or if it is used on a node other than a Document Node, the empty sequence is returned.
    /// It is defined on all seven node kinds.
    pub fn document_uri(self: *NodeInterface) ?[]u8 {
        return self.document_uri_fn(self);
    }

    /// TODO : dm:is-id($node as node()) as xs:boolean?
    ///
    /// The dm:is-id accessor returns true if the node is an XML ID. Exactly what constitutes an ID depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
    /// It is defined on all seven node kinds.
    pub fn is_id(self: *NodeInterface) bool {
        return self.is_id_fn(self);
    }

    /// TODO : dm:is-idrefs($node as node()) as xs:boolean?
    ///
    /// The dm:is-idrefs accessor returns true if the node is an XML IDREF or IDREFS. Exactly what constitutes an IDREF or IDREFS depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
    // It is defined on all seven node kinds.
    pub fn is_idrefs(self: *NodeInterface) bool {
        return self.is_idrefs_fn(self);
    }

    /// TODO : dm:namespace-nodes($n as node()) as node()*
    ///
    /// The dm:namespace-nodes accessor returns the dynamic, in-scope namespaces associated with a node as a sequence containing zero or more Namespace Nodes. The order of Namespace Nodes is stable but implementation dependent.
    /// It is defined on all seven node kinds.
    pub fn namespace_nodes(self: *NodeInterface) []*NodeInterface {
        return self.namespace_nodes_fn(self);
    }

    /// TODO : dm:nilled($n as node()) as xs:boolean?
    ///
    /// The dm:nilled accessor returns true if the node is "nilled". [Schema Part 1] introduced the nilled mechanism to signal that an element should be accepted as valid when it has no content even when it has a content type which does not require or even necessarily allow empty content.
    /// It is defined on all seven node kinds.
    pub fn nilled(self: *NodeInterface) bool {
        return self.nilled_fn(self);
    }

    /// dm:node-kind($n as node()) as xs:string
    ///
    /// The dm:node-kind accessor returns a string identifying the kind of node. It will be one of the following, depending on the kind of node: “attribute”, “comment”, “document”, “element”, “namespace” “processing-instruction”, or “text”.
    /// It is defined on all seven node kinds.
    pub fn node_kind(self: *NodeInterface) []const u8 {
        return self.node_kind_fn(self);
    }

    /// dm:node-name($n as node()) as xs:QName?
    ///
    /// The dm:node-name accessor returns the name of the node as a sequence of zero or one xs:QNames. Note that the QName value includes an optional prefix as described in 3.3.3 QNames and NOTATIONS.
    /// It is defined on all seven node kinds.
    pub fn node_name(self: *NodeInterface) ?QName {
        return self.node_name_fn(self);
    }

    /// TODO : dm:parent($n as node()) as node()?
    ///
    /// The dm:parent accessor returns the parent of a node as a sequence containing zero or one nodes.
    /// It is defined on all seven node kinds.
    pub fn parent(self: *NodeInterface) ?*NodeInterface {
        return self.parent_fn(self);
    }

    /// TODO : dm:string-value($n as node()) as xs:string
    ///
    /// The dm:string-value accessor returns the string value of a node.
    /// It is defined on all seven node kinds.
    pub fn string_value(self: *NodeInterface) []u8 {
        return self.string_value_fn(self);
    }

    /// TODO : dm:type-name($n as node()) as xs:QName?
    ///
    /// The dm:type-name accessor returns the name of the schema type of a node as a sequence of zero or one xs:QNames.
    /// It is defined on all seven node kinds.
    pub fn type_name(self: *NodeInterface) ?QName {
        return self.type_name_fn(self);
    }

    /// TODO : dm:typed-value($n as node()) as xs:anyAtomicType*
    ///
    /// The dm:typed-value accessor returns the typed-value of the node as a sequence of zero or more atomic values.
    /// It is defined on all seven node kinds.
    pub fn typed_value(self: *NodeInterface) []anyAtomicType {
        return self.typed_value_fn(self);
    }

    /// TODO : dm:unparsed-entity-public-id($node as node(), $entityname as xs:string) as xs:string?
    ///
    /// The dm:unparsed-entity-public-id accessor returns the public identifier of an unparsed external entity declared in the specified document.
    /// If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, or if the entity has no public identifier, the empty sequence is returned.
    /// It is defined on all seven node kinds.
    pub fn unparsed_entity_public_id(self: *NodeInterface, entityname: []u8) []u8 {
        return self.unparsed_entity_public_id_fn(self, entityname);
    }

    /// TODO : dm:unparsed-entity-system-id($node as node(), $entityname as xs:string) as xs:anyURI?
    /// The dm:unparsed-entity-system-id accessor returns the system identifier of an unparsed external entity declared in the specified document. The value is an absolute URI, and is obtained by resolving the [system identifier] of the unparsed entity information item against the [declaration base URI] of the same item. If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, the empty sequence is returned.
    /// It is defined on all seven node kinds.
    pub fn unparsed_entity_system_id(self: *NodeInterface, entityname: []u8) []u8 {
        return self.unparsed_entity_system_id_fn(self, entityname);
    }
};
