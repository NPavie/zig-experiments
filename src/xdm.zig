// implementation of XDM 3.1 in zig
// reference : https://www.w3.org/TR/xpath-datamodel-31/
const std = @import("std");

const NS_XS = "http://www.w3.org/2001/XMLSchema";
const NS_XSI = "http://www.w3.org/2001/XMLSchema-instance";
const NS_FN = "http://www.w3.org/2005/xpath-functions";


const  QName = struct {
	namespace: []const u8,
	prefix: []const u8,
	localName: []const u8,

	pub fn equal(self: QName, other: QName) bool {
		return (
			std.mem.eql(u8, self.namespace, other.namespace) and 
			std.mem.eql(u8, self.localName, other.localName)
		);
	}
};

const PrimitiveType = enum {
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

// 5. Accessors
// A set of accessors is defined on nodes in the data model. 
// For consistency, all the accessors are defined on every kind of node, although several accessors return a constant empty sequence on some kinds of nodes.

// TDB : dm:attributes($n as node()) as attribute()*
//The dm:attributes accessor returns the attributes of a node as a sequence containing zero or more Attribute Nodes. The order of Attribute Nodes is stable but implementation dependent.
//It is defined on all seven node kinds.

// TBD : dm:base-uri($n as node()) as xs:anyURI?
//The dm:base-uri accessor returns the base URI of a node as a sequence containing zero or one URI reference. For more information about base URIs, see [XML Base].
//It is defined on all seven node kinds

// TBD : dm:children($n as node()) as node()*
// The dm:children accessor returns the children of a node as a sequence containing zero or more nodes.
// It is defined on all seven node kinds.

// TBD : dm:document-uri($node as node()) as xs:anyURI?
//The dm:document-uri accessor returns the absolute URI of the resource from which the Document Node was constructed, if the absolute URI is available. If there is no URI available, or if it cannot be made absolute when the Document Node is constructed, or if it is used on a node other than a Document Node, the empty sequence is returned.
//It is defined on all seven node kinds.

// TBD : dm:is-id($node as node()) as xs:boolean?
// The dm:is-id accessor returns true if the node is an XML ID. Exactly what constitutes an ID depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
// It is defined on all seven node kinds.

// TBD : dm:is-idrefs($node as node()) as xs:boolean?
// The dm:is-idrefs accessor returns true if the node is an XML IDREF or IDREFS. Exactly what constitutes an IDREF or IDREFS depends in part on how the data model was constructed, see 6.2 Element Nodes and 6.3 Attribute Nodes.
// It is defined on all seven node kinds.

// TBD : dm:namespace-nodes($n as node()) as node()*
// The dm:namespace-nodes accessor returns the dynamic, in-scope namespaces associated with a node as a sequence containing zero or more Namespace Nodes. The order of Namespace Nodes is stable but implementation dependent.
// It is defined on all seven node kinds.

// TBD : dm:nilled($n as node()) as xs:boolean?
// The dm:nilled accessor returns true if the node is "nilled". [Schema Part 1] introduced the nilled mechanism to signal that an element should be accepted as valid when it has no content even when it has a content type which does not require or even necessarily allow empty content.
// It is defined on all seven node kinds.

// TBD : dm:node-kind($n as node()) as xs:string
// The dm:node-kind accessor returns a string identifying the kind of node. It will be one of the following, depending on the kind of node: “attribute”, “comment”, “document”, “element”, “namespace” “processing-instruction”, or “text”.
// It is defined on all seven node kinds.

// TBD : dm:node-name($n as node()) as xs:QName?
// The dm:node-name accessor returns the name of the node as a sequence of zero or one xs:QNames. Note that the QName value includes an optional prefix as described in 3.3.3 QNames and NOTATIONS.
// It is defined on all seven node kinds.

// TBD : dm:parent($n as node()) as node()?
// The dm:parent accessor returns the parent of a node as a sequence containing zero or one nodes.
// It is defined on all seven node kinds.

// TBD : dm:string-value($n as node()) as xs:string
// The dm:string-value accessor returns the string value of a node.
// It is defined on all seven node kinds.

// TBD : dm:type-name($n as node()) as xs:QName?
// The dm:type-name accessor returns the name of the schema type of a node as a sequence of zero or one xs:QNames.
// It is defined on all seven node kinds.

// TBD : dm:typed-value($n as node()) as xs:anyAtomicType*
// The dm:typed-value accessor returns the typed-value of the node as a sequence of zero or more atomic values.
// It is defined on all seven node kinds.

// TBD : dm:unparsed-entity-public-id($node as node(), $entityname as xs:string) as xs:string?
// The dm:unparsed-entity-public-id accessor returns the public identifier of an unparsed external entity declared in the specified document.
// If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, or if the entity has no public identifier, the empty sequence is returned.
// It is defined on all seven node kinds.

// dm:unparsed-entity-system-id($node as node(), $entityname as xs:string) as xs:anyURI?
// The dm:unparsed-entity-system-id accessor returns the system identifier of an unparsed external entity declared in the specified document. The value is an absolute URI, and is obtained by resolving the [system identifier] of the unparsed entity information item against the [declaration base URI] of the same item. If no entity with the name specified in $entityname exists, or if the entity is not an external unparsed entity, the empty sequence is returned.
// It is defined on all seven node kinds.

const NodeType = enum {
	document,
	element,
	attribute,
	text,
	namespace,
	processing_instruction,
	comment,
};

// TODO : create a Node stuct that have a NodeType that have all previous accessor, and based on the "NodeType", should have 
const Node = struct {
	_type: NodeType,
	attributes: ?[]*Node,
	children: ?[]*Node,
	value_type: ?PrimitiveType
};