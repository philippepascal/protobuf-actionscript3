//
// Generates AS3 code for a given .proto file.

#ifndef GOOGLE_PROTOBUF_COMPILER_AS3_GENERATOR_H__
#define GOOGLE_PROTOBUF_COMPILER_AS3_GENERATOR_H__

#include <string>
#include <google/protobuf/compiler/code_generator.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace as3 {

// CodeGenerator implementation which generates AS3 code.
class LIBPROTOC_EXPORT As3Generator : public CodeGenerator {
 public:
  As3Generator();
  ~As3Generator();

  // implements CodeGenerator ----------------------------------------
  bool Generate(const FileDescriptor* file,
                const string& parameter,
                OutputDirectory* output_directory,
                string* error) const;

 private:
  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(As3Generator);
};

}  // namespace as3
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_AS3_GENERATOR_H__
