# Introduction #

Although relatively small in code change, fixing the 64bits primitive handling induced 2 consequences:
# 64 bits are supported -> new feature
# The project is now depending on an oustide library: as3crypto
Therefore the version number got bumped to 2.0

As of 2.2, version 2.2 (same number is a coincidence) of protobuf is supported, and as a consequence previous versions are not.

# Details #

## What was wrong with 64 bits ##

All the implementation was using Number to store the 64 bits of int64 and uint64. Although Number does have 64 bits, it uses only 53 for the mantissa, the rest is for the exponent and the sign. So the precision was wrong. Moreover, it seem to me that bitwise operator in actionscript only handle 32 bits. So whatever mask manipulation on 64 bits was compiling, but not doing much.

## How it was fixed ##

There is unfortunately no support for 64 bits int in actionscript, so instead of using an array of two int and writing hard to read code, I used the nice BigInteger implementation from the as3crypto project (very good project, BTW). It's a port of the java BigInteger, and the only tricky part I found is the creator: it takes a reverse order ByteArray, of which you have to make sure to set the position to 0, or specify the length in the radix parameter. There is also no support (yet?) for decimal representation (that I know of at least), only radix 16.

## bottom line ##

The compilator now uses the type BigInteger for all 64 bits int in messages, and the as3 library write/read BigIntegers to/from the ByteArray streams of the wired content.

## remaining question ##

I might have oversimplified one method: "writeInt32" was forking to either writeRawVarint32 or writeRawVarint64, and I'm not sure why. Bottom line is that writeInt32 takes a Number, and I didn't want to have to change that to BigInteger. maybe it's alright, but I don't have time to investigate that right now.

# Misc #

I recently changed the default value of enum fields to -1: this allow to detect if the field was set or not, instead of giving a value of 0 or 1 which is probably a valid enum value.