// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.
// http://code.google.com/p/protobuf/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: Robert Blackwood (ported from Kenton's)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#include <map>
#include <string>

#include <google/protobuf/compiler/as3/as3_primitive_field.h>
#include <google/protobuf/stubs/common.h>
#include <google/protobuf/compiler/as3/as3_helpers.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/stubs/strutil.h>
#include <google/protobuf/stubs/substitute.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace as3 {

namespace {

const char* PrimitiveTypeName(As3Type type) {
  switch (type) {
    case AS3TYPE_INT    : return "int";
    case AS3TYPE_LONG   : return "BigInteger";
    case AS3TYPE_FLOAT  : return "Number";
    case AS3TYPE_DOUBLE : return "Number";
    case AS3TYPE_BOOLEAN: return "Boolean";
    case AS3TYPE_STRING : return "String";
    case AS3TYPE_BYTES  : return "ByteArray";
    case AS3TYPE_ENUM   : return NULL;
    case AS3TYPE_MESSAGE: return NULL;

    // No default because we want the compiler to complain if any new
    // As3Types are added.
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

const char* GetCapitalizedType(const FieldDescriptor* field) {
  switch (field->type()) {
    case FieldDescriptor::TYPE_INT32   : return "Int32"   ;
    case FieldDescriptor::TYPE_UINT32  : return "UInt32"  ;
    case FieldDescriptor::TYPE_SINT32  : return "SInt32"  ;
    case FieldDescriptor::TYPE_FIXED32 : return "Fixed32" ;
    case FieldDescriptor::TYPE_SFIXED32: return "SFixed32";
    case FieldDescriptor::TYPE_INT64   : return "Int64"   ;
    case FieldDescriptor::TYPE_UINT64  : return "UInt64"  ;
    case FieldDescriptor::TYPE_SINT64  : return "SInt64"  ;
    case FieldDescriptor::TYPE_FIXED64 : return "Fixed64" ;
    case FieldDescriptor::TYPE_SFIXED64: return "SFixed64";
    case FieldDescriptor::TYPE_FLOAT   : return "Float"   ;
    case FieldDescriptor::TYPE_DOUBLE  : return "Double"  ;
    case FieldDescriptor::TYPE_BOOL    : return "Bool"    ;
    case FieldDescriptor::TYPE_STRING  : return "String"  ;
    case FieldDescriptor::TYPE_BYTES   : return "Bytes"   ;
    case FieldDescriptor::TYPE_ENUM    : return "Enum"    ;
    case FieldDescriptor::TYPE_GROUP   : return "Group"   ;
    case FieldDescriptor::TYPE_MESSAGE : return "Message" ;

    // No default because we want the compiler to complain if any new
    // types are added.
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

bool AllPrintableAscii(const string& text) {
  // Cannot use isprint() because it's locale-specific.  :(
  for (int i = 0; i < text.size(); i++) {
    if ((text[i] < 0x20) || text[i] >= 0x7F) {
      return false;
    }
  }
  return true;
}

string DefaultValue(const FieldDescriptor* field) {
  // Switch on cpp_type since we need to know which default_value_* method
  // of FieldDescriptor to call.
  switch (field->cpp_type()) {
    case FieldDescriptor::CPPTYPE_INT32:
      return SimpleItoa(field->default_value_int32());
    case FieldDescriptor::CPPTYPE_UINT32:
      // Need to print as a signed int since As3 has no unsigned.
      return SimpleItoa(static_cast<int32>(field->default_value_uint32()));
    case FieldDescriptor::CPPTYPE_INT64:
		  return "new BigInteger("+SimpleItoa(field->default_value_int64())+")";
//		  return SimpleItoa(field->default_value_int64());
//		  return SimpleItoa(field->default_value_int64()) + "L";
	case FieldDescriptor::CPPTYPE_UINT64:
		  return "new BigInteger("+SimpleItoa(static_cast<int64>(field->default_value_uint64()))+")";
//		  return SimpleItoa(static_cast<int64>(field->default_value_uint64()));
//		  return SimpleItoa(static_cast<int64>(field->default_value_uint64())) + "L";
    case FieldDescriptor::CPPTYPE_DOUBLE:
		  return SimpleDtoa(field->default_value_double());
//		  return SimpleDtoa(field->default_value_double()) + "D";
    case FieldDescriptor::CPPTYPE_FLOAT:
		  return SimpleFtoa(field->default_value_float());
//		  return SimpleFtoa(field->default_value_float()) + "F";
    case FieldDescriptor::CPPTYPE_BOOL:
      return field->default_value_bool() ? "true" : "false";
    case FieldDescriptor::CPPTYPE_STRING: {
      bool isBytes = field->type() == FieldDescriptor::TYPE_BYTES;

      if (!isBytes && AllPrintableAscii(field->default_value_string())) {
        // All chars are ASCII and printable.  In this case CEscape() works
        // fine (it will only escape quotes and backslashes).
        // Note:  If this "optimization" is removed, DescriptorProtos will
        //   no longer be able to initialize itself due to bootstrapping
        //   problems.
        return "\"" + CEscape(field->default_value_string()) + "\"";
      }

      if (isBytes && !field->has_default_value()) {
        return "new ByteArray()";
      }

      // Escaping strings correctly for As3 and generating efficient
      // initializers for ByteStrings are both tricky.  We can sidestep the
      // whole problem by just grabbing the default value from the descriptor.
      return strings::Substitute(
        "(($0) $1.getDescriptor().getFields().get($2).getDefaultValue())",
        isBytes ? "com.google.protobuf.ByteString" : "String",
        ClassName(field->containing_type()), field->index());
    }

    case FieldDescriptor::CPPTYPE_ENUM:
    case FieldDescriptor::CPPTYPE_MESSAGE:
      GOOGLE_LOG(FATAL) << "Can't get here.";
      return "";

    // No default because we want the compiler to complain if any new
    // types are added.
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return "";
}

void SetPrimitiveVariables(const FieldDescriptor* descriptor,
                           map<string, string>* variables) {
  (*variables)["name"] =
    UnderscoresToCamelCase(descriptor);
  (*variables)["capitalized_name"] =
    UnderscoresToCapitalizedCamelCase(descriptor);
  (*variables)["number"] = SimpleItoa(descriptor->number());
  (*variables)["type"] = PrimitiveTypeName(GetAs3Type(descriptor));
  (*variables)["boxed_type"] = BoxedPrimitiveTypeName(GetAs3Type(descriptor));
  (*variables)["default"] = DefaultValue(descriptor);
  (*variables)["capitalized_type"] = GetCapitalizedType(descriptor);
  (*variables)["parent"] = descriptor->containing_type()->name();

}

}  // namespace

// ===================================================================

PrimitiveFieldGenerator::
PrimitiveFieldGenerator(const FieldDescriptor* descriptor)
  : descriptor_(descriptor) {
  SetPrimitiveVariables(descriptor, &variables_);
}

PrimitiveFieldGenerator::~PrimitiveFieldGenerator() {}

void PrimitiveFieldGenerator::
GenerateMembers(io::Printer* printer) const {
  printer->Print(variables_,
	"public var $name$:$type$ = $default$;\n");
}

void PrimitiveFieldGenerator::
GenerateBuilderMembers(io::Printer* printer) const {
  printer->Print(variables_,
	"public function get$capitalized_name$():$type$  {\n"
    "  return $name$;\n"
    "}\n"
	"public function set$capitalized_name$(value:$type$):$parent$ {\n"
    "  $name$ = value;\n"
    "  return this;\n"
    "}\n"
	"public function clear$capitalized_name$():$parent$ {\n"
    "  $name$ = $default$;\n"
    "  return this;\n"
    "}\n");
}

void PrimitiveFieldGenerator::
GenerateMergingCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (other.has$capitalized_name$()) {\n"
    "  set$capitalized_name$(other.get$capitalized_name$());\n"
    "}\n");
}

void PrimitiveFieldGenerator::
GenerateBuildingCode(io::Printer* printer) const {
  // Nothing to do here for primitive types.
}

void PrimitiveFieldGenerator::
GenerateParsingCode(io::Printer* printer) const {
  printer->Print(variables_,
    "set$capitalized_name$(input.read$capitalized_type$());\n");
}

void PrimitiveFieldGenerator::
GenerateSerializationCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (has$capitalized_name$()) {\n"
    "  output.write$capitalized_type$($number$, get$capitalized_name$());\n"
    "}\n");
}

void PrimitiveFieldGenerator::
GenerateSerializedSizeCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (has$capitalized_name$()) {\n"
    "  size += com.google.protobuf.CodedOutputStream\n"
    "    .compute$capitalized_type$Size($number$, get$capitalized_name$());\n"
    "}\n");
}

string PrimitiveFieldGenerator::GetBoxedType() const {
  return BoxedPrimitiveTypeName(GetAs3Type(descriptor_));
}

// ===================================================================

RepeatedPrimitiveFieldGenerator::
RepeatedPrimitiveFieldGenerator(const FieldDescriptor* descriptor)
  : descriptor_(descriptor) {
  SetPrimitiveVariables(descriptor, &variables_);
}

RepeatedPrimitiveFieldGenerator::~RepeatedPrimitiveFieldGenerator() {}

void RepeatedPrimitiveFieldGenerator::
GenerateMembers(io::Printer* printer) const {
  printer->Print(variables_,
	"public var $name$:Array = new Array();"
    "\n");
}

void RepeatedPrimitiveFieldGenerator::
GenerateBuilderMembers(io::Printer* printer) const {
  printer->Print(variables_,
	"public function get$capitalized_name$List():Array {\n"
    "  return $name$;\n"
    "}\n"
	"public function get$capitalized_name$Count():int {\n"
    "  return $name$.length;\n"
    "}\n"
	"public function get$capitalized_name$(index:int):$type$ {\n"
	"  return $name$[index];\n"
    "}\n"
	"public function set$capitalized_name$(index:int, value:$type$):$parent$ {\n"
	"  $name$[index] = value;\n"
    "  return this;\n"
    "}\n"
	"public function add$capitalized_name$(value:$type$):$parent$ {\n"
    //"  if ($name$_.isEmpty()) {\n"
    //"    $name$_ = new ArrayList<$boxed_type$>();\n"
    //"  }\n"
    "  $name$.push(value);\n"
    "  return this;\n"
    "}\n"
	"public function addAll$capitalized_name$(values:Array):$parent$ {\n"
    //"  if ($name$_.isEmpty()) {\n"
    //"    $name$_ = new ArrayList<$boxed_type$>();\n"
    //"  }\n"
    "  $name$.concat(values);\n"
    "  return this;\n"
    "}\n"
	"public function clear$capitalized_name$():$parent$  {\n"
	"  $name$ = new Array();\n"
    "  return this;\n"
    "}\n");
}

void RepeatedPrimitiveFieldGenerator::
GenerateMergingCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (!other.$name$_.isEmpty()) {\n"
    "  if ($name$_.isEmpty()) {\n"
    "    $name$_ = new ArrayList<$boxed_type$>();\n"
    "  }\n"
    "  $name$_.addAll(other.$name$_);\n"
    "}\n");
}

void RepeatedPrimitiveFieldGenerator::
GenerateBuildingCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if ($name$_ != Collections.EMPTY_LIST) {\n"
    "  $name$_ =\n"
    "    Collections.unmodifiableList($name$_);\n"
    "}\n");
}

void RepeatedPrimitiveFieldGenerator::
GenerateParsingCode(io::Printer* printer) const {
  printer->Print(variables_,
    "add$capitalized_name$(input.read$capitalized_type$());\n");
}

void RepeatedPrimitiveFieldGenerator::
GenerateSerializationCode(io::Printer* printer) const {
  printer->Print(variables_,
	"for (var element:$type$ , get$capitalized_name$List()) {\n"
    "  output.write$capitalized_type$($number$, element);\n"
    "}\n");
}

void RepeatedPrimitiveFieldGenerator::
GenerateSerializedSizeCode(io::Printer* printer) const {
  printer->Print(variables_,
	  "for (var element:$type$, get$capitalized_name$List()) {\n"
    "  size += com.google.protobuf.CodedOutputStream\n"
    "    .compute$capitalized_type$Size($number$, element);\n"
    "}\n");
}

string RepeatedPrimitiveFieldGenerator::GetBoxedType() const {
  return BoxedPrimitiveTypeName(GetAs3Type(descriptor_));
}

}  // namespace as3
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
