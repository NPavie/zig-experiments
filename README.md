# Zig experiments

Some of my experiments with the zig language

actually trying to make SAX parser for XML 1.1 with zig, to be used for other side project
like an xml formatter to pretty print or linearize xml



// Notes pour implementation d'un selecteur de version (demande a chatgpt de résumé les différences entre les version 1.1 et 1.0 de la specification XML )
// Les spécifications du format XML 1.1 ont introduit quelques changements par rapport à la version 1.0 pour résoudre des problèmes liés à l'utilisation internationale et à la compatibilité avec d'autres standards. Voici les principales différences entre XML 1.0 et XML 1.1 :
//
// 1. Jeu de caractères
// XML 1.1 élargit la gamme des caractères autorisés dans les noms (comme les noms d'éléments et d'attributs). Cela inclut des caractères supplémentaires provenant des langues écrites récemment codifiées dans Unicode.
// Les restrictions sur les caractères de contrôle ont été assouplies dans XML 1.1 :
// Certains caractères de contrôle non imprimables (U+0001 à U+001F) sont désormais autorisés, à condition qu'ils soient représentés en tant qu'entités de caractère (par exemple, &#x1F;).
// Cela permet une meilleure prise en charge des systèmes qui utilisent ces caractères dans des données encodées.
// 2. Nouvelle gestion des retours à la ligne
// XML 1.1 a introduit une normalisation plus stricte des caractères de fin de ligne.
// Tous les caractères de saut de ligne (U+000D CR, U+000A LF et U+0085 NEL) sont normalisés en U+000A (LF) lors du traitement.
// Cela permet une meilleure compatibilité entre différentes plateformes, notamment celles qui utilisent des conventions de fin de ligne différentes.
// 3. Compatibilité descendante
// XML 1.1 a été conçu pour être largement compatible avec XML 1.0. Cependant, les documents XML 1.1 ne sont pas toujours interprétables par des processeurs XML conformes uniquement à XML 1.0.
// Les documents doivent explicitement déclarer leur version dans la déclaration XML :
// Exemple pour XML 1.1 : <?xml version="1.1"?>.
// 4. Utilisation des caractères Unicode mis à jour
// XML 1.1 suit une version plus récente du standard Unicode (Unicode 3.1 ou ultérieur à l'époque de sa publication). Cela inclut un plus grand nombre de caractères disponibles pour les documents.
// 5. Manipulation des caractères interdits
// XML 1.1 a également resserré ou clarifié certaines règles concernant les caractères explicitement interdits (par exemple, U+0000 reste interdit sauf s'il est encodé comme une entité de caractère).
// En résumé :
// XML 1.1 est une évolution mineure qui vise à améliorer l'internationalisation et la portabilité, en assouplissant certaines contraintes sur les caractères tout en maintenant une compatibilité relative avec XML 1.0. Cependant, il n'a pas été largement adopté en raison de la stabilité et de la popularité de XML 1.0.

// XML 1.1 defined entities
// document = ( prolog element Misc* ) - ( Char* RestrictedChar Char* )
// Char : [#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
// RestrictedChar = [#x1-#x8] | [#xB-#xC] | [#xE-#x1F] | [#x7F-#x84] | [#x86-#x9F]
//              = char de control , vtab et formfeed, char de contol, + d'autres champ unicode
// Discouraged character = [#x1-#x8], [#xB-#xC], [#xE-#x1F], [#x7F-#x84], [#x86-#x9F], [#xFDD0-#xFDDF],
//                         [#x1FFFE-#x1FFFF], [#x2FFFE-#x2FFFF], [#x3FFFE-#x3FFFF],
//                         [#x4FFFE-#x4FFFF], [#x5FFFE-#x5FFFF], [#x6FFFE-#x6FFFF],
//                         [#x7FFFE-#x7FFFF], [#x8FFFE-#x8FFFF], [#x9FFFE-#x9FFFF],
//                         [#xAFFFE-#xAFFFF], [#xBFFFE-#xBFFFF], [#x.cFFFE-#x.cFFFF],
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
// Note : en 1.0, XMLDecl est optionnel
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

// STag	= '<' Name (S Attribute)* S? '>'
// Attribute = Name Eq AttValue
// AttValue = '"' ([^<&"] | Reference)* '"' |  "'" ([^<&'] | Reference)* "'"

// IsPEReference = '%' Name ';'
// Reference = EntityRef | CharRef
// EntityRef =  '&' Name ';'
// CharRef = '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'
// ETag	= '</' Name S? '>'

//	ExternalID	   ::=   	'SYSTEM' S SystemLiteral | 'PUBLIC' S PubidLiteral S SystemLiteral
//   	NDataDecl	   ::=   	S 'NDATA' S Name

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

// Si je reprend ce que j'ai vu sur d'autres parseur
// pour chaque sous block de XML, ils ont une fonction qui vérifie puis parse du contenu
// Par exemple, en state "Empty"/"DocStart", on appelle une fonction parseXMLDecl
// qui cherche le texte

