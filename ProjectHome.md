### The ultimate protobuf actionscript project ###

Credit to Robert Blackwood for starting the effort with the initial protocol-buffers-actionscript project that was used as a start for this project.

A fair amount of work has been put in to make it usable in real life environment:
  1. GPB make file works on Mac
  1. compiler result is now usable (no compilation error for actionscript packages or files)
  1. message generator has been simplified and adapted to action script
  1. infinite level of message nesting is now supported
  1. 64 bits int are correctly supported

A nice to have for improving the project would be handling of enums. Right now, they are just plain int.

Suggestion have also been made to optionally remove BigInteger dependency for sake of lightness and speed.

Contributions are more than welcome, contact me (sorrydevil@gmail.com), and I'll be happy to add you to the project.

Philippe.

### Status ###
Version 2.2 had issued inherent to the introduction of protobuf-2.2. The known bugs are fixed as part of protobuf-actionscript3-2.3.
Version 2.3 has been uploaded http://code.google.com/p/protobuf-actionscript3/wiki/version_2_0.

### Dependencies ###
As of 2.0, the project depends on the BigInteger of the as3crypto project. Make sure to download as3crypto.swc in your project, and pay a visit to their great project ( http://code.google.com/p/as3crypto/ ).

### Misc ###
The repo is a bit ahead of the release as a patch from Jesse was applied. I will release once tested.

As of 2.2, protobufv2.2 is supported. Concretely that means that the makefiles (.am and .in) are modified version of protobuf2.2s' and a line has been changed in the generator for an interface change. If you still use protobufv2.0.3, stick to the release 2.1... or switch altogether!
Thanks to Andy Tso and holybreath (I like the name:) for their contributions: very much appreciated.