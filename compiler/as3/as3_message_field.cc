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

#include <google/protobuf/compiler/as3/as3_message_field.h>
#include <google/protobuf/compiler/as3/as3_helpers.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/wire_format.h>
#include <google/protobuf/stubs/strutil.h>
namespace google {
namespace protobuf {
namespace compiler {
namespace as3 {

namespace {

// TODO(kenton):  Factor out a "SetCommonFieldVariables()" to get rid of
//   repeat code between this and the other field types.
void SetMessageVariables(const FieldDescriptor* descriptor,
                         map<string, string>* variables) {
	string package = FileAs3Package(descriptor->message_type()->file());
  (*variables)["name"] =
    UnderscoresToCamelCase(descriptor);
  (*variables)["capitalized_name"] =
    UnderscoresToCapitalizedCamelCase(descriptor);
  (*variables)["number"] = SimpleItoa(descriptor->number());
  if(!package.empty()) {
    (*variables)["java_package"] = package.append(".");
  } else {
    (*variables)["java_package"] = package;
  }
  (*variables)["type"] = descriptor->message_type()->name();
  (*variables)["label"] = SimpleItoa(descriptor->label());
  (*variables)["parent"] = descriptor->containing_type()->name();
  (*variables)["group_or_message"] =
    (descriptor->type() == FieldDescriptor::TYPE_GROUP) ?
    "Group" : "Message";
}

}  // namespace

// ===================================================================

MessageFieldGenerator::
MessageFieldGenerator(const FieldDescriptor* descriptor)
  : descriptor_(descriptor) {
  SetMessageVariables(descriptor, &variables_);
}

MessageFieldGenerator::~MessageFieldGenerator() {}

void MessageFieldGenerator::
GenerateMembers(io::Printer* printer) const {	
	printer->Print(variables_,
				   "public var $name$:$java_package$$type$ = null;\n");}

void MessageFieldGenerator::
GenerateBuilderMembers(io::Printer* printer) const {
  printer->Print(variables_,
	"public function get$capitalized_name$():$type$ {\n"
    "  return $name$;\n"
    "}\n"
	"public function set$capitalized_name$(value:$type$):$parent$ {\n"
    "  $name$ = value;\n"
    "  return this;\n"
    "}\n"
	//"public function set$capitalized_name$(builderForValue:$type$.Builder):Builder {\n"
 //   "  result.has$capitalized_name$ = true;\n"
 //   "  result.$name$_ = builderForValue.build();\n"
 //   "  return this;\n"
 //   "}\n"
	"public function clear$capitalized_name$():$parent$ {\n"
    "  $name$ = $type$.getDefaultInstance();\n"
    "  return this;\n"
    "}\n");
}

void MessageFieldGenerator::
GenerateMergingCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (other.has$capitalized_name$()) {\n"
    "  merge$capitalized_name$(other.get$capitalized_name$());\n"
    "}\n");
}

void MessageFieldGenerator::
GenerateBuildingCode(io::Printer* printer) const {
  // Nothing to do for singular fields.
}

void MessageFieldGenerator::
GenerateParsingCode(io::Printer* printer) const {
  //printer->Print(variables_,
  //  "$type$.Builder subBuilder = $type$.newBuilder();\n"
  //  "if (has$capitalized_name$()) {\n"
  //  "  subBuilder.mergeFrom(get$capitalized_name$());\n"
  //  "}\n");

  //if (descriptor_->type() == FieldDescriptor::TYPE_GROUP) {
  //  printer->Print(variables_,
  //    "input.readGroup($number$, subBuilder, extensionRegistry);\n");
  //} else {
  //  printer->Print(variables_,
  //    "input.readMessage(subBuilder, extensionRegistry);\n");
  //}

  //printer->Print(variables_,
  //  "set$capitalized_name$(subBuilder.buildPartial());\n");
}

void MessageFieldGenerator::
GenerateSerializationCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (has$capitalized_name$()) {\n"
    "  output.write$group_or_message$($number$, get$capitalized_name$());\n"
    "}\n");
}

void MessageFieldGenerator::
GenerateSerializedSizeCode(io::Printer* printer) const {
  printer->Print(variables_,
    "if (has$capitalized_name$()) {\n"
    "  size += com.google.protobuf.CodedOutputStream\n"
    "    .compute$group_or_message$Size($number$, get$capitalized_name$());\n"
    "}\n");
}

string MessageFieldGenerator::GetBoxedType() const {
  return ClassName(descriptor_->message_type());
}

// ===================================================================

RepeatedMessageFieldGenerator::
RepeatedMessageFieldGenerator(const FieldDescriptor* descriptor)
  : descriptor_(descriptor) {
  SetMessageVariables(descriptor, &variables_);
}

RepeatedMessageFieldGenerator::~RepeatedMessageFieldGenerator() {}

void RepeatedMessageFieldGenerator::
GenerateMembers(io::Printer* printer) const {
  printer->Print(variables_,
	  "public var $name$:Array = new Array();\n\n"
	  "//fix bug 1 protobuf-actionscript3\n"
	  "//dummy var using $java_package$ necessary to avoid following exception\n"
	  "//ReferenceError: Error #1065: Variable NetworkInfo is not defined.\n"
	  "//at global/flash.utils::getDefinitionByName()\n"
	  "//at com.google.protobuf::Message/readFromCodedStream()\n"
	  "private var $name$Dummy:$java_package$$type$ = null;\n");
}

void RepeatedMessageFieldGenerator::
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

void RepeatedMessageFieldGenerator::
GenerateMergingCode(io::Printer* printer) const {
  //printer->Print(variables_,
  //  "if (!other.$name$_.isEmpty()) {\n"
  //  "  if (result.$name$_.isEmpty()) {\n"
  //  "    result.$name$_ = new as3.util.ArrayList<$type$>();\n"
  //  "  }\n"
  //  "  result.$name$_.addAll(other.$name$_);\n"
  //  "}\n");
}

void RepeatedMessageFieldGenerator::
GenerateBuildingCode(io::Printer* printer) const {
  //printer->Print(variables_,
  //  "if (result.$name$_ != as3.util.Collections.EMPTY_LIST) {\n"
  //  "  result.$name$_ =\n"
  //  "    as3.util.Collections.unmodifiableList(result.$name$_);\n"
  //  "}\n");
}

void RepeatedMessageFieldGenerator::
GenerateParsingCode(io::Printer* printer) const {
  //printer->Print(variables_,
  //  "var subBuilder;$type$.Builder = $type$.newBuilder();\n");

  //if (descriptor_->type() == FieldDescriptor::TYPE_GROUP) {
  //  printer->Print(variables_,
  //    "input.readGroup($number$, subBuilder, extensionRegistry);\n");
  //} else {
  //  printer->Print(variables_,
  //    "input.readMessage(subBuilder, extensionRegistry);\n");
  //}

  //printer->Print(variables_,
  //  "add$capitalized_name$(subBuilder.buildPartial());\n");
}

void RepeatedMessageFieldGenerator::
GenerateSerializationCode(io::Printer* printer) const {
 // printer->Print(variables_,
	//"for (var element:$type$ in get$capitalized_name$List()) {\n"
 //   "  output.write$group_or_message$($number$, element);\n"
 //   "}\n");
}

void RepeatedMessageFieldGenerator::
GenerateSerializedSizeCode(io::Printer* printer) const {
 // printer->Print(variables_,
	//"for (var element:$type$ in get$capitalized_name$List()) {\n"
 //   "  size += com.google.protobuf.CodedOutputStream\n"
 //   "    .compute$group_or_message$Size($number$, element);\n"
 //   "}\n");
}

string RepeatedMessageFieldGenerator::GetBoxedType() const {
  return ClassName(descriptor_->message_type());
}

}  // namespace as3
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
