// implementation of XDM 3.1 in zig
// reference : https://www.w3.org/TR/xpath-datamodel-31/
const std = @import("std");

// TODO : Implementing data types from https://www.w3.org/TR/xmlschema11-2/#built-in-datatypes


//2.7.2 Predefined Types
// In addition to the 19 types defined in Section 3.2 Primitive datatypesXS2 of [Schema Part 2], the data model defines five additional types: xs:anyAtomicType, xs:untyped, xs:untypedAtomic, xs:dayTimeDuration, and xs:yearMonthDuration. These types are defined in the XML Schema namespace with permission of the XML Schema Working Group; in implementations that support [Schema 1.1 Part 2], the XSD 1.1 definitions of xs:anyAtomicType, xs:dayTimeDuration, and xs:yearMonthDuration supersede the definitions in this specification.

// Type wrappers from the spec
const numeric = union(enum) {
	integer: i32,
	decimal: f64,
	float: f32,
	double: f64
};

/// Duration value as defined in https://www.w3.org/TR/xmlschema11-2/#duration
const duration = struct {
	months:i64,
	decimal: f64
};

const anyAtomicType = union(enum){
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


const  QName = struct {
	uri: []const u8,
	prefix: []const u8,
	localName: []const u8,

	pub fn equal(self: QName, other: QName) bool {
		return (
			std.mem.eql(u8, self.namespace, other.namespace) and 
			std.mem.eql(u8, self.localName, other.localName)
		);
	}
};

// 6. Nodes

pub const DocumentNode = struct {
	base_uri: ?[]u8,
	children: ?[]union(enum){
		element:*ElementNode,
		processing_instruction:*ProcessingInstructionNode,
		comment:*CommentNode,
		text:*TextNode,
	},
	unparsed_entities: ?[]u8,
	document_uri: ?[]u8,
	string_value: []u8,
	typed_value: []u8,
};


const ElementNode = struct{
	base_uri: ?[]u8,
	node_name: QName,
	parent: ?union(enum){
		element:*ElementNode,
		document:*DocumentNode,
	},
	schema_type: []u8,
	children: []union(enum){
		element:*ElementNode,
		processing_instruction:*ProcessingInstructionNode,
		comment:*CommentNode,
		text:*TextNode,
	},
	attributes: ?[]*AttributeNode,
	namespaces: ?[]*NamespaceNode,
	string_value: []u8,
	typed_value: []u8,
	nilled: bool,
	is_id: bool,
	is_idrefs: bool,
};

const AttributeNode = struct{
	node_name:QName,
	parent:?*ElementNode,
	schema_type:[]u8,
	string_value:[]u8,
	typed_value:[]u8,
	is_id:bool,
	is_idrefs:bool,
};

const NamespaceNode = struct{
	prefix:?[]u8,
	uri:[]u8,
	parent:?Node,

};


const ProcessingInstructionNode = struct{
	target:[]u8,
	content:[]u8,
	base_uri:?[]u8,
	parent:?[]u8,
};

const CommentNode = struct{
	content:[]u8,
	parent:?*Node
};
const TextNode = struct{
	content:[]u8,
	parent:?*Node
};



const NodeType = enum {
	document,
	element,
	attribute,
	text,
	namespace,
	processing_instruction ,
	comment,
};




pub const Node = union(NodeType) {
	document:*DocumentNode,
	element:*ElementNode,
	attribute:*AttributeNode,
	text:*TextNode,
	namespace:*NamespaceNode,
	processing_instruction:*ProcessingInstructionNode ,
	comment:*CommentNode,
	unknown,
	// _type: NodeType,
	// _node_name: ?QName,
	// _parent: ?*Node,
	// _document: ?*Node,
	// _attributes: ?[]*Node,
	// _children: ?[]*Node,
	// _namespaces: ?[]*Node,
	// _base_uri: []u8,
	// _string_value:[]u8,
	// _typed_value: AnyType,
	// _is_id:bool = false,
	// _is_idref:bool = false,
	// _nilled:bool = false,
	// _unparsed_entities: [][]u8,


	//_value_type: ?AnyType,

	// 5. Accessors
	// A set of accessors is defined on nodes in the data model. 
	// For consistency, all the accessors are defined on every kind of node, although several accessors return a constant empty sequence on some kinds of nodes.

	/// dm:attributes($n as node()) as attribute()*
	/// 
	/// The dm:attributes accessor returns the attributes of a node as a sequence containing zero or more Attribute Nodes. The order of Attribute Nodes is stable but implementation dependent.
	/// It is defined on all seven node kinds.
	fn attributes(self: Node) []*AttributeNode {
		return switch (self) {
			Node.element => self.element.attributes,
			_ => .{}
		};
	}

	/// TODO : dm:base-uri($n as node()) as xs:anyURI?
	///
	///The dm:base-uri accessor returns the base URI of a node as a sequence containing zero or one URI reference. For more information about base URIs, see https://www.w3.org/TR/xmlbase/.
	///It is defined on all seven node kinds
	fn base_uri(self: Node) ?[]u8 {
		_ = self;
	} // as xs:anyURI?

	/// TODO : dm:children($n as node()) as node()*
	///
	/// The dm:children accessor returns the children of a node as a sequence containing zero or more nodes.
	/// It is defined on all seven node kinds.
	fn children(self: Node) []*Node {
		_ = self;
	} // as node()*

	/// TODO : dm:document-uri($node as node()) as xs:anyURI?
	/// 
	/// The dm:document-uri accessor returns the absolute URI of the resource from which the Document Node was constructed, if the absolute URI is available. If there is no URI available, or if it cannot be made absolute when the Document Node is constructed, or if it is used on a node other than a Document Node, the empty sequence is returned.
	/// It is defined on all seven node kinds.
	fn document_uri(self: Node) ?[]u8 {
		_ = self;
	} // as xs:anyURI?

	/// TODO : dm:is-id($node as node()) as xs:boolean?
	///
	/// The dm:is-id accessor returns true if the node is an XML ID. Exactly what constitutes an ID depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
	/// It is defined on all seven node kinds.
	fn is_id(self: Node) bool {
		_ = self;
	} // as xs:boolean?

	/// TODO : dm:is-idrefs($node as node()) as xs:boolean?
	///
	/// The dm:is-idrefs accessor returns true if the node is an XML IDREF or IDREFS. Exactly what constitutes an IDREF or IDREFS depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
	// It is defined on all seven node kinds.
	fn is_idrefs(self: Node) bool {
		_ = self;
	} // as xs:boolean?

	/// TODO : dm:namespace-nodes($n as node()) as node()*
	///
	/// The dm:namespace-nodes accessor returns the dynamic, in-scope namespaces associated with a node as a sequence containing zero or more Namespace Nodes. The order of Namespace Nodes is stable but implementation dependent.
	/// It is defined on all seven node kinds.
	fn namespace_nodes(self: Node) []*Node {
		_ = self;
	} // as node()*


	/// TODO : dm:nilled($n as node()) as xs:boolean?
	///
	/// The dm:nilled accessor returns true if the node is "nilled". [Schema Part 1] introduced the nilled mechanism to signal that an element should be accepted as valid when it has no content even when it has a content type which does not require or even necessarily allow empty content.
	/// It is defined on all seven node kinds.
	fn nilled(self: Node) bool {
		_ = self;
	} // as xs:boolean?
	
	
	/// dm:node-kind($n as node()) as xs:string
	///
	/// The dm:node-kind accessor returns a string identifying the kind of node. It will be one of the following, depending on the kind of node: “attribute”, “comment”, “document”, “element”, “namespace” “processing-instruction”, or “text”.
	/// It is defined on all seven node kinds.
	fn node_kind(self: Node) []const u8{
		return switch(self._type) {
			NodeType.document => "document",
			NodeType.element => "element",
			NodeType.attribute => "attribute",
			NodeType.text => "text",
			NodeType.namespace => "namespace",
			NodeType.processing_instruction => "processing_instruction",
			NodeType.comment => "comment",
		};
	}

	/// dm:node-name($n as node()) as xs:QName?
	///
	/// The dm:node-name accessor returns the name of the node as a sequence of zero or one xs:QNames. Note that the QName value includes an optional prefix as described in 3.3.3 QNames and NOTATIONS.
	/// It is defined on all seven node kinds.
	fn node_name(self: Node) ?QName {
		return self._node_name;
	} // as xs:QName?

	/// TODO : dm:parent($n as node()) as node()?
	///
	/// The dm:parent accessor returns the parent of a node as a sequence containing zero or one nodes.
	/// It is defined on all seven node kinds.
	fn parent(self: Node) ?*Node {
		return self._parent;
	} // as node()?

	/// TODO : dm:string-value($n as node()) as xs:string
	///
	/// The dm:string-value accessor returns the string value of a node.
	/// It is defined on all seven node kinds.
	fn string_value(self: Node) []u8 {
		_ = self;
	} // as xs:string

	/// TODO : dm:type-name($n as node()) as xs:QName?
	///
	/// The dm:type-name accessor returns the name of the schema type of a node as a sequence of zero or one xs:QNames.
	/// It is defined on all seven node kinds.
	fn type_name(self: Node) ?QName {
		_ = self;
	} // as xs:QName?

	
	/// TODO : dm:typed-value($n as node()) as xs:anyAtomicType*
	///
	/// The dm:typed-value accessor returns the typed-value of the node as a sequence of zero or more atomic values.
	/// It is defined on all seven node kinds.
	fn typed_value(self: Node) []anyAtomicType {
		_ = self;
	} // as xs:anyAtomicType*

	
	/// TODO : dm:unparsed-entity-public-id($node as node(), $entityname as xs:string) as xs:string?
	///
	/// The dm:unparsed-entity-public-id accessor returns the public identifier of an unparsed external entity declared in the specified document.
	/// If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, or if the entity has no public identifier, the empty sequence is returned.
	/// It is defined on all seven node kinds.
	fn unparsed_entity_public_id(self: Node, entityname: []u8) []u8 {
		_ = self;
		_ = entityname;
	} // as xs:string?

	
	/// TODO : dm:unparsed-entity-system-id($node as node(), $entityname as xs:string) as xs:anyURI?
	/// The dm:unparsed-entity-system-id accessor returns the system identifier of an unparsed external entity declared in the specified document. The value is an absolute URI, and is obtained by resolving the [system identifier] of the unparsed entity information item against the [declaration base URI] of the same item. If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, the empty sequence is returned.
	/// It is defined on all seven node kinds.
	fn unparsed_entity_system_id(self: Node, entityname: []u8) []u8 {
		_ = self;
		_ = entityname;
	}

};

pub fn Document(alloc:std.mem.Allocator)!Node{
	_ = alloc;

}