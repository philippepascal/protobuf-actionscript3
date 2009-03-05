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

// Author: kenton@google.com (Kenton Varda)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#ifndef GOOGLE_PROTOBUF_COMPILER_AS3_HELPERS_H__
#define GOOGLE_PROTOBUF_COMPILER_AS3_HELPERS_H__

#include <string>
#include <google/protobuf/descriptor.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace as3 {

// Commonly-used separator comments.  Thick is a line of '=', thin is a line
// of '-'.
extern const char kThickSeparator[];
extern const char kThinSeparator[];

// Converts the field's name to camel-case, e.g. "foo_bar_baz" becomes
// "fooBarBaz" or "FooBarBaz", respectively.
string UnderscoresToCamelCase(const FieldDescriptor* field);
string UnderscoresToCapitalizedCamelCase(const FieldDescriptor* field);

// Similar, but for method names.  (Typically, this merely has the effect
// of lower-casing the first letter of the name.)
string UnderscoresToCamelCase(const MethodDescriptor* method);

// Strips ".proto" or ".protodevel" from the end of a filename.
string StripProto(const string& filename);

// Gets the unqualified class name for the file.  Each .proto file becomes a
// single As3 class, with all its contents nested in that class.
string FileClassName(const FileDescriptor* file);

// Returns the file's As3 package name.
string FileAs3Package(const FileDescriptor* file);

// Converts the given fully-qualified name in the proto namespace to its
// fully-qualified name in the As3 namespace, given that it is in the given
// file.
string ToAs3Name(const string& full_name, const FileDescriptor* file);

// These return the fully-qualified class name corresponding to the given
// descriptor.
inline string ClassName(const Descriptor* descriptor) {
  return ToAs3Name(descriptor->full_name(), descriptor->file());
}
inline string ClassName(const EnumDescriptor* descriptor) {
  return ToAs3Name(descriptor->full_name(), descriptor->file());
}
inline string ClassName(const ServiceDescriptor* descriptor) {
  return ToAs3Name(descriptor->full_name(), descriptor->file());
}
string ClassName(const FileDescriptor* descriptor);

enum As3Type {
  AS3TYPE_INT,
  AS3TYPE_LONG,
  AS3TYPE_FLOAT,
  AS3TYPE_DOUBLE,
  AS3TYPE_BOOLEAN,
  AS3TYPE_STRING,
  AS3TYPE_BYTES,
  AS3TYPE_ENUM,
  AS3TYPE_MESSAGE
};

As3Type GetAs3Type(FieldDescriptor::Type field_type);

inline As3Type GetAs3Type(const FieldDescriptor* field) {
  return GetAs3Type(field->type());
}

// Get the fully-qualified class name for a boxed primitive type, e.g.
// "as3.lang.Integer" for AS3TYPE_INT.  Returns NULL for enum and message
// types.
const char* BoxedPrimitiveTypeName(As3Type type);

}  // namespace as3
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_AS3_HELPERS_H__
