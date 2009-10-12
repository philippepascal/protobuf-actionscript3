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

package com.google.protobuf
{	
	import com.hurlant.math.BigInteger;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	/**
	 * Reads and decodes protocol message fields.
	 *
	 * @author Robert Blackwood
	 * -ported from kenton's java implementation
	 */
	public class CodedInputStream {
	  /**
	   * Create a new CodedInputStream wrapping the given InputStream.
	   */
	  public static function newInstance(input:IDataInput):CodedInputStream {
	    return new CodedInputStream(input);
	  }
	
	  // -----------------------------------------------------------------
	
	  /**
	   * Attempt to read a field tag, returning zero if we have reached EOF.
	   * Protocol message parsers use this to read tags, since a protocol message
	   * may legally end wherever a tag occurs, and zero is not a valid tag number.
	   */
	  public function readTag():int {
	  	
	  	if ( input.bytesAvailable != 0)
		    lastTag = readRawVarint32();
		else 
			lastTag = 0;
	    
	    return lastTag;
	  }
	
	  /**
	   * Verifies that the last call to readTag() returned the given tag value.
	   * This is used to verify that a nested group ended with the correct
	   * end tag.
	   *
	   * @throws InvalidProtocolBufferException {@code value} does not match the
	   *                                        last tag.
	   */
	  public function checkLastTagWas(value:int):void {
	    if (lastTag != value) {
	      throw InvalidProtocolBufferException.invalidEndTag();
	    }
	  }
	
	  /**
	   * Reads and discards a single field, given its tag value.
	   *
	   * @return {@code false} if the tag is an endgroup tag, in which case
	   *         nothing is skipped.  Otherwise, returns {@code true}.
	   */
	  public function skipField(tag:int):Boolean {
	    switch (WireFormat.getTagWireType(tag)) {
	      case WireFormat.WIRETYPE_VARINT:
	        readInt32();
	        return true;
	      case WireFormat.WIRETYPE_FIXED64:
	        readRawLittleEndian64();
	        return true;
	      case WireFormat.WIRETYPE_LENGTH_DELIMITED:
	        skipRawBytes(readRawVarint32());
	        return true;
	      case WireFormat.WIRETYPE_START_GROUP:
	        skipMessage();
	        checkLastTagWas(
	          WireFormat.makeTag(WireFormat.getTagFieldNumber(tag),
	                             WireFormat.WIRETYPE_END_GROUP));
	        return true;
	      case WireFormat.WIRETYPE_END_GROUP:
	        return false;
	      case WireFormat.WIRETYPE_FIXED32:
	        readRawLittleEndian32();
	        return true;
	      default:
	        throw InvalidProtocolBufferException.invalidWireType();
	    }
	  }
	
	  /**
	   * Reads and discards an entire message.  This will read either until EOF
	   * or until an endgroup tag, whichever comes first.
	   */
	  public function skipMessage():void {
	    while (true) {
	      var tag:int = readTag();
	      if (tag == 0 || !skipField(tag)) return;
	    }
	  }
	
	  // -----------------------------------------------------------------
	
	  /** Read a {@code double} field value from the stream. */
	  public function readDouble():BigInteger {
	    return readRawLittleEndian64();
	  }
	
	  /** Read a {@code float} field value from the stream. */
	  public function readFloat():Number {
	    return readRawLittleEndian32();
	  }
	
	  /** Read a {@code uint64} field value from the stream. */
	  public function readUInt64():BigInteger {
	    return readRawVarint64();
	  }
	
	  /** Read an {@code int64} field value from the stream. */
	  public function readInt64():BigInteger {
	    return readRawVarint64();
	  }
	
	  /** Read an {@code int32} field value from the stream. */
	  public function readInt32():int {
	    return readRawVarint32();
	  }
	
	  /** Read a {@code fixed64} field value from the stream. */
	  public function readFixed64():BigInteger {
	    return readRawLittleEndian64();
	  }
	
	  /** Read a {@code fixed32} field value from the stream. */
	  public function readFixed32():int {
	    return readRawLittleEndian32();
	  }
	
	  /** Read a {@code bool} field value from the stream. */
	  public function readBool():Boolean {
	    return readRawVarint32() != 0;
	  }
	
	  /** Read a {@code string} field value from the stream. */
	  public function readString():String 
	  {
	    var size:int = readRawVarint32();
	    return new String(readRawBytes(size));
	  }
	
	  /** Read a {@code group} field value from the stream. */
	  /*public function readGroup(fieldNumber:int, builder:Message.Builder,
	                        extensionRegistry:ExtensionRegistry):void {

	    builder.mergeFrom(this, extensionRegistry);
	    checkLastTagWas(WireFormat.makeTag(fieldNumber, WireFormat.WIRETYPE_END_GROUP));

	  }*/
	
	  /**
	   * Reads a {@code group} field value from the stream and merges it into the
	   * given {@link UnknownFieldSet}.
	   */
	 /* public function readUnknownGroup(fieldNumber:int, builder:UnknownFieldSet.Builder):void {
	    builder.mergeFrom(this);
	    checkLastTagWas(WireFormat.makeTag(fieldNumber, WireFormat.WIRETYPE_END_GROUP));

	  }*/
	
	  /** Read an embedded message field value from the stream. */
	  /*public function readMessage(builder:Message.Builder,
	                          extensionRegistry:ExtensionRegistry):void {
	    length:int = readRawVarint32();
	    builder.mergeFrom(this, extensionRegistry);
	    checkLastTagWas(0);
	  }*/
	
	  /** Read a {@code bytes} field value from the stream. */
	  public function readBytes():ByteArray {
	    var size:int = readRawVarint32();
	    return readRawBytes(size);
	  }
	
	  /** Read a {@code uint32} field value from the stream. */
	  public function readUInt32():int {
	    return readRawVarint32();
	  }
	
	  /**
	   * Read an enum field value from the stream.  Caller is responsible
	   * for converting the numeric value to an actual enum.
	   */
	  public function readEnum(): int {
	    return readRawVarint32();
	  }
	
	  /** Read an {@code sfixed32} field value from the stream. */
	  public function readSFixed32():int{
	    return readRawLittleEndian32();
	  }
	
	  /** Read an {@code sfixed64} field value from the stream. */
	  public function readSFixed64():BigInteger {
	    return readRawLittleEndian64();
	  }
	
	  /** Read an {@code sint32} field value from the stream. */
	  public function readSInt32():int {
	    return decodeZigZag32(readRawVarint32());
	  }
	
	  /** Read an {@code sint64} field value from the stream. */
	  public function readSInt64():BigInteger {
	    return decodeZigZag64(readRawVarint64());
	  }
	  
	 /**
	   * Read a field of a given wire type.  
	   * 
	   * @param type Declared type of the field.
	   * @return An object representing the field's value, of the exact
	   *         type which would be returned by
	   *         {@link Message#getField(Descriptors.FieldDescriptor)} for
	   *         this field.
	   */
	  public function  readPrimitiveField(type:int):Object {
	  	
	    switch (type) {
	      case Descriptor.DOUBLE  : return readDouble  ();
	      case Descriptor.FLOAT   : return readFloat   ();
	      case Descriptor.INT64   : return readInt64   ();
	      case Descriptor.UINT64  : return readUInt64  ();
	      case Descriptor.INT32   : return readInt32   ();
	      case Descriptor.FIXED64 : return readFixed64 ();
	      case Descriptor.FIXED32 : return readFixed32 ();
	      case Descriptor.BOOL    : return readBool    ();
	      case Descriptor.STRING  : return readString  ();
	      case Descriptor.BYTES   : return readBytes   ();
	      case Descriptor.UINT32  : return readUInt32  ();
	      case Descriptor.SFIXED32: return readSFixed32();
	      case Descriptor.SFIXED64: return readSFixed64();
	      case Descriptor.SINT32  : return readSInt32  ();
	      case Descriptor.SINT64  : return readSInt64  ();
	      //fix bug 1 protobuf-actionscript3
		  case Descriptor.ENUM    : return readEnum    ();
	
		  default: 
		  	trace("Unknown primative field type: " + type); 
		  	break;
	    }
	
	    return null;
	  }
	
	  // =================================================================
	
	  /**
	   * Read a raw Varint from the stream.  If larger than 32 bits, discard the
	   * upper bits.
	   */
	  public function readRawVarint32():int {
	    var tmp:int = readRawByte();
	    if (tmp >= 0) {
	      return tmp;
	    }
	    var result:int = tmp & 0x7f;
	    if ((tmp = readRawByte()) >= 0) {
	      result |= tmp << 7;
	    } else {
	      result |= (tmp & 0x7f) << 7;
	      if ((tmp = readRawByte()) >= 0) {
	        result |= tmp << 14;
	      } else {
	        result |= (tmp & 0x7f) << 14;
	        if ((tmp = readRawByte()) >= 0) {
	          result |= tmp << 21;
	        } else {
	          result |= (tmp & 0x7f) << 21;
	          result |= (tmp = readRawByte()) << 28;
	          if (tmp < 0) {
	            // Discard upper 32 bits.
	            for (var i:int = 0; i < 5; i++) {
	              if (readRawByte() >= 0) return result;
	            }
	            throw InvalidProtocolBufferException.malformedVarint();
	          }
	        }
	      }
	    }
	    return result;
	  }
	
	  /** Read a raw Varint from the stream. */
	  public function readRawVarint64():BigInteger {
	    var shift:int = 0;
	    var result:BigInteger = BigInteger.ZERO.clone();
	    while (shift < 64) {
	      //read a byte a create a BigInteger with it
	      var b:int = readRawByte();
		  var ba:ByteArray = new ByteArray();
		  ba.writeByte(b & 0x7F);
		  ba.position=0;
		  var bb:BigInteger = new BigInteger(ba);
		  //shift the byte to its position and set it in the result
	      bb = bb.shiftLeft(shift);
	      result = result.or(bb);
	      //are we done or do we continue
	      if ((b & 0x80) == 0) return result;
	      shift += 7;
	    }
	    throw InvalidProtocolBufferException.malformedVarint();
	  }
	
	  /** Read a 32-bit little-endian integer from the stream. */
	  public function readRawLittleEndian32():int {
	    var b1:int = readRawByte();
	    var b2:int = readRawByte();
	    var b3:int = readRawByte();
	    var b4:int = readRawByte();
	    return ((b1 & 0xff)      ) |
	           ((b2 & 0xff) <<  8) |
	           ((b3 & 0xff) << 16) |
	           ((b4 & 0xff) << 24);
	  }
	
	  /** Read a 64-bit little-endian integer from the stream. */
	  public function readRawLittleEndian64():BigInteger {
	  	//tricky: BigInteger takes an array with heaviest byte first!
	  	//reverse from the stream
	  	
		var b1:int = readRawByte();
	    var b2:int = readRawByte();
	    var b3:int = readRawByte();
	    var b4:int = readRawByte();
	    var b5:int = readRawByte();
	    var b6:int = readRawByte();
	    var b7:int = readRawByte();
	    var b8:int = readRawByte();
	  	
	  	var ba:ByteArray = new ByteArray();
	  	ba.writeByte(b8);
	  	ba.writeByte(b7);
	  	ba.writeByte(b6);
	  	ba.writeByte(b5);
	  	ba.writeByte(b4);
	  	ba.writeByte(b3);
	  	ba.writeByte(b2);
	  	ba.writeByte(b1);
	  	ba.position = 0;
	  	return new BigInteger(ba);
	  }
	
	  /**
	   * Decode a ZigZag-encoded 32-bit value.  ZigZag encodes signed integers
	   * into values that can be efficiently encoded with varint.  (Otherwise,
	   * negative values must be sign-extended to 64 bits to be varint encoded,
	   * thus always taking 10 bytes on the wire.)
	   *
	   * @param n An unsigned 32-bit integer, stored in a signed int because
	   *          Java has no explicit unsigned support.
	   * @return A signed 32-bit integer.
	   */
	  public static function decodeZigZag32(n:int):int {
	    return (n >>> 1) ^ -(n & 1);
	  }
	
	  /**
	   * Decode a ZigZag-encoded 64-bit value.  ZigZag encodes signed integers
	   * into values that can be efficiently encoded with varint.  (Otherwise,
	   * negative values must be sign-extended to 64 bits to be varint encoded,
	   * thus always taking 10 bytes on the wire.)
	   *
	   * @param n An unsigned 64-bit integer, stored in a signed int because
	   *          Java has no explicit unsigned support.
	   * @return A signed 64-bit integer.
	   */
	  public static function decodeZigZag64(n:BigInteger):BigInteger {
	  	var nA:BigInteger = n.shiftRight(1);
	  	var nB:BigInteger = n.and(BigInteger.ONE);
	  	return nA.xor(nB);
	    //return (n >>> 1) ^ -(n & 1);
	  }
	
	  // -----------------------------------------------------------------
	
	  private var bufferSize:int;
	  private var bufferSizeAfterLimit:int = 0;
	  private var bufferPos:int = 0;
	  private var input:IDataInput;
	  private var lastTag:int = 0;
	
	  /** See setSizeLimit() */
	  private var sizeLimit:int = DEFAULT_SIZE_LIMIT;
	
	  private static const DEFAULT_RECURSION_LIMIT:int = 64;
	  private static const DEFAULT_SIZE_LIMIT:int = 64 << 20;  // 64MB
	
	  public function CodedInputStream(input:IDataInput) {
	    this.bufferSize = 0;
	    this.input = input;
	  }
	
	  /**
	   * Read one byte from the input.
	   *
	   * @throws InvalidProtocolBufferException The end of the stream or the current
	   *                                        limit was reached.
	   */
	  public function readRawByte():int {
	  	//lame, wait until buffer is full enough
	  	//while(bytesAvailable() == 0) {}
	  	
	    return input.readByte();
	  }
	
	  /**
	   * Read a fixed size of bytes from the input.
	   *
	   * @throws InvalidProtocolBufferException The end of the stream or the current
	   *                                        limit was reached.
	   */
	  public function readRawBytes(size:int):ByteArray {
	    if (size < 0) {
	      throw InvalidProtocolBufferException.negativeSize();
	    }
	    
	    //lame, wait until buffer is full enough
		//while (bytesAvailable() < size) {}			
	    
	    var bytes:ByteArray = new ByteArray();
	    
	    if(size != 0)
	      input.readBytes(bytes,0,size);
	    
	    return bytes;
	  }
	
	  /**
	   * Reads and discards {@code size} bytes.
	   *
	   * @throws InvalidProtocolBufferException The end of the stream or the current
	   *                                        limit was reached.
	   */
	  public function skipRawBytes(size:int):void 
	  {
		readRawBytes(size);
	  }
	}
}
