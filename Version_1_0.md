# Introduction #

The first working version of the project is checked-in and available for download.


# Details #

Here are the main differences with the protocol-buffers-actionscript project from which it was spinned off:

  1. compiling a set of complex proto files produce workable, compilable action script files
  1. all messages are separated into their own actionscript file, with a proper package definition and link to one another.
  1. all getters/setters have been removed from generation because they were not working as is. they replaced by a simple public variable. Since there was no logic in getters/setters I don't see that as a drawback.
  1. enums are simply defined as numbers. non inner Enums generate a simple AS file with the definition of their values. inner Enums are for the moment ignored (TODO).
  1. inner messages are generated up to three levels. This needs to be redesigned to be processed recursively.
  1. imports are automatically added in generated code for the AS based classes and the generated classes.
  1. examples have been changed to be closer to a realistic proto files set.

# Bug fixes #

Version 1.0.1 (trunk [revision 5](https://code.google.com/p/protobuf-actionscript3/source/detail?r=5)) introduce a bunch of fixes with nested messages.

Version 1.0.2 (trunk [revision 7](https://code.google.com/p/protobuf-actionscript3/source/detail?r=7)) fix a null pointer exception in CodedOutputStream.

Version 1.0.3 (trunk [revision 10](https://code.google.com/p/protobuf-actionscript3/source/detail?r=10)) fix the handling of nested messages in CodedOutputStream

---

I feel like I'm forgetting something, so please download and try, and give me feed back. Once again participant are more than welcome as I certainly can't do this on my own.