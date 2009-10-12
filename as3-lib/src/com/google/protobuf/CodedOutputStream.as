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
	import flash.utils.IDataOutput;
	
	/**
	 * Encodes and writes protocol message fields.
	 *
	 * @author Robert Blackwood
	 * -ported from kenton's java implementation
	 */
	public final class CodedOutputStream {
	  //private final var buffer:ByteArray;
	  private var limit:int;
	  private var position:int;
	
	  private var output:IDataOutput;
	
	  /**
	   * The buffer size used in {@link #newInstance(java.io.OutputStream)}.
	   */
	  public static const DEFAULT_BUFFER_SIZE:int = 4096;
	
	  public function CodedOutputStream(output:IDataOutput) {
	    this.output = output;
	    this.limit = DEFAULT_BUFFER_SIZE;
	  }
	
	  /**
	   * Create a new {@code CodedOutputStream} wrapping the given
	   * {@code OutputStream}.
	   */
	  public static function newInstance(output:IDataOutput):CodedOutputStream {
	    return new CodedOutputStream(output);
	  }
	
	  // -----------------------------------------------------------------
	
	  /** Write a {@code double} field, including tag, to the stream. */
	  public function writeDouble(fieldNumber:int, value:BigInteger):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_FIXED64);
	    writeRawLittleEndian64(value);
	  }
	
	  /** Write a {@code float} field, including tag, to the stream. */
	  public function writeFloat(fieldNumber:int, value:Number):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_FIXED32);
	    writeRawLittleEndian32(value);
	  }
	
	  /** Write a {@code uint64} field, including tag, to the stream. */
	  public function writeUInt64(fieldNumber:int, value:BigInteger):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawVarint64(value);
	  }
	
	  /** Write an {@code int64} field, including tag, to the stream. */
	  public function writeInt64(fieldNumber:int, value:BigInteger):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawVarint64(value);
	  }
	
	  /** Write an {@code int32} field, including tag, to the stream. */
	  public function writeInt32(fieldNumber:int, value:Number):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    //Not sure why this...
	    /*
	    if (value >= 0) {
	      writeRawVarint32(value);
	    } 
	    else {
	      // Must sign-extend.
	      writeRawVarint64(value);
	    }
	    */
	    writeRawVarint32(value);
	  }
	
	  /** Write a {@code fixed64} field, including tag, to the stream. */
	  public function writeFixed64(fieldNumber:int, value:BigInteger):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_FIXED64);
	    writeRawLittleEndian64(value);
	  }
	
	  /** Write a {@code fixed32} field, including tag, to the stream. */
	  public function writeFixed32(fieldNumber:int, value:int):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_FIXED32);
	    writeRawLittleEndian32(value);
	  }
	
	  /** Write a {@code bool} field, including tag, to the stream. */
	  public function writeBool(fieldNumber:int, value:Boolean):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawByte(value ? 1 : 0);
	  }
	
	  /** Write a {@code string} field, including tag, to the stream. */
	  public function writeString(fieldNumber:int, value:String):void  {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_LENGTH_DELIMITED);
	    // Not sure if size() on value is reliable because we actually
	    // want the number of bytes first... not the number of characters
	    // which may be more than one byte (kenton did this too for java) -rkb
	    var bytes:ByteArray = new ByteArray();
	    bytes.writeUTFBytes(value);
	    writeRawVarint32(bytes.length);
	    writeRawBytes(bytes);
	  }
	
	  /** Write a {@code group} field, including tag, to the stream. */
	  /*public function writeGroup(fieldNumber:int, value:AbstractMessage):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_START_GROUP);
	    value.writeToCodedStream(this,);
	    writeTag(fieldNumber, WireFormat.WIRETYPE_END_GROUP);
	  }*/
	
	  /** Write a group represented by an {@link UnknownFieldSet}. */
	  /*public function writeUnknownGroup(fieldNumber:int, value:UnknownFieldSet):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_START_GROUP);
	    value.writeTo(this);
	    writeTag(fieldNumber, WireFormat.WIRETYPE_END_GROUP);
	  }*/
	
	  /** Write an embedded message field, including tag, to the stream. */
	  public function writeMessage(fieldNumber:int, value:Message):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_LENGTH_DELIMITED);
	    var tempStream:ByteArray = new ByteArray();
	    value.writeToDataOutput(tempStream);
	    tempStream.position = 0;
	    writeRawVarint32(tempStream.length);
	    output.writeBytes(tempStream,0,tempStream.length);
	  }
	  
	
	  /** Write a {@code bytes} field, including tag, to the stream. */
	  public function writeBytes(fieldNumber:int, value:ByteArray):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_LENGTH_DELIMITED);
	    value.position = 0;
	    writeRawVarint32(value.length);
	    writeRawBytes(value);
	  }
	
	  /** Write a {@code uint32} field, including tag, to the stream. */
	  public function writeUInt32(fieldNumber:int, value:int):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawVarint32(value);
	  }
	
	  /**
	   * Write an enum field, including tag, to the stream.  Caller is responsible
	   * for converting the enum value to its numeric value.
	   */
	  public function writeEnum(fieldNumber:int, value:int):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawVarint32(value);
	  }
	
	  /** Write an {@code sfixed32} field, including tag, to the stream. */
	  public function writeSFixed32(fieldNumber:int, value:int):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_FIXED32);
	    writeRawLittleEndian32(value);
	  }
	
	  /** Write an {@code sfixed64} field, including tag, to the stream. */
	  public function writeSFixed64(fieldNumber:int, value:BigInteger):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_FIXED64);
	    writeRawLittleEndian64(value);
	  }
	
	  /** Write an {@code sint32} field, including tag, to the stream. */
	  public function writeSInt32(fieldNumber:int, value:int):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawVarint32(encodeZigZag32(value));
	  }
	
	  /** Write an {@code sint64} field, including tag, to the stream. */
	  public function writeSInt64(fieldNumber:int, value:BigInteger):void {
	    writeTag(fieldNumber, WireFormat.WIRETYPE_VARINT);
	    writeRawVarint64(encodeZigZag64(value));
	  }
	
	  /**
	   * Write a MessageSet extension field to the stream.  For historical reasons,
	   * the wire format differs from normal fields.
	   */
	  /*public function writeMessageSetExtension(fieldNumber:int, value:AbstractMessage):void
	  {
	    writeTag(WireFormat.MESSAGE_SET_ITEM, WireFormat.WIRETYPE_START_GROUP);
	    writeUInt32(WireFormat.MESSAGE_SET_TYPE_ID, fieldNumber);
	    writeMessage(WireFormat.MESSAGE_SET_MESSAGE, value);
	    writeTag(WireFormat.MESSAGE_SET_ITEM, WireFormat.WIRETYPE_END_GROUP);
	  }*/
	
	  /**
	   * Write an unparsed MessageSet extension field to the stream.  For
	   * historical reasons, the wire format differs from normal fields.
	   */
	  /*public function writeRawMessageSetExtension(fieldNumber:int, value:String):void
	  {
	    writeTag(WireFormat.MESSAGE_SET_ITEM, WireFormat.WIRETYPE_START_GROUP);
	    writeUInt32(WireFormat.MESSAGE_SET_TYPE_ID, fieldNumber);
	    writeBytes(WireFormat.MESSAGE_SET_MESSAGE, value);
	    writeTag(WireFormat.MESSAGE_SET_ITEM, WireFormat.WIRETYPE_END_GROUP);
	  }*/
	   
	 /**
	   * Write a field of arbitrary type, including tag, to the stream.
	   *
	   * @param type   The field's type.
	   * @param number The field's number.
	   * @param value  Object representing the field's value.  Must be of the exact
	   *               type which would be returned by
	   *               {@link Message#getField(Descriptors.FieldDescriptor)} for
	   *               this field.
	   */
	  public function writeField(number:int, value:*):void {
	    
	    if (value is String)
	    	writeString(number, (value as String));
	    else if (value is Boolean) 
	    	writeBool(number, (value as Boolean));
	    else if (value is uint) 
	    	writeUInt32(number, (value as uint));
	    else if (value is int)
	     	writeInt32(number, (value as int));
	    else if (value is BigInteger)
	    	writeInt64(number, (value as BigInteger));
	    else if (value is ByteArray)
	    	writeBytes(number, (value as ByteArray));
	    else
	    	throw  new InvalidProtocolBufferException( "Tried to write primative field type, but type was not valid");
	    	
	  }
	  
	  public static function computeFieldSize(number:int, value:*):int {
	    
	    if (value is String)
	    	return computeStringSize(number, (value as String));
	    else if (value is Boolean) 
	    	return computeBoolSize(number, (value as Boolean));
	    else if (value is uint) 
	    	return computeUInt32Size(number, (value as uint));
	    else if (value is int)
	     	return computeInt32Size(number, (value as int));
	    else if (value is Number)
	    	return computeInt64Size(number, (value as BigInteger));
	    else if ( value is Message )
		    return value.getSerializedSize();	
	    else
	    	throw  new InvalidProtocolBufferException( "Could not compute size of field, type was not valid");
	  }
      /*
      case DOUBLE  : writeDouble
      case FLOAT   : writeFloat   
      case INT64   : writeInt64   
      case UINT64  : writeUInt64  
      case INT32   : writeInt32   
      case FIXED64 : writeFixed64 
      case FIXED32 : writeFixed32
      case BOOL    : writeBool   
      case STRING  : writeString  
      case GROUP   : writeGroup   
      case MESSAGE : writeMessage 
      case BYTES   : writeBytes   
      case UINT32  : writeUInt32  
      case SFIXED32: writeSFixed32(
      case SFIXED64: writeSFixed64
      case SINT32  : writeSInt32  
      case SINT64  : writeSInt64  
      */

	
	  // =================================================================
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code double} field, including tag.
	   */
	  public static function computeDoubleSize(fieldNumber:int, value:Number):int {
	    return computeTagSize(fieldNumber) + LITTLE_ENDIAN_64_SIZE;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code float} field, including tag.
	   */
	  public static function computeFloatSize(fieldNumber:int, value:Number):int {
	    return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code uint64} field, including tag.
	   */
	  public static function computeUInt64Size(fieldNumber:int, value:BigInteger):int {
	    return computeTagSize(fieldNumber) + computeRawVarint64Size(value);
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * {@code int64} field, including tag.
	   */
	  public static function computeInt64Size(fieldNumber:int, value:BigInteger):int {
	    return computeTagSize(fieldNumber) + computeRawVarint64Size(value);
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * {@code int32} field, including tag.
	   */
	  public static function computeInt32Size(fieldNumber:int, value:int):int {
	    if (value >= 0) {
	      return computeTagSize(fieldNumber) + computeRawVarint32Size(value);
	    } else {
	      // Must sign-extend.
	      return computeTagSize(fieldNumber) + 10;
	    }
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code fixed64} field, including tag.
	   */
	  public static function computeFixed64Size(fieldNumber:int, value:Number):int {
	    return computeTagSize(fieldNumber) + LITTLE_ENDIAN_64_SIZE;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code fixed32} field, including tag.
	   */
	  public static function computeFixed32Size(fieldNumber:int, value:int):int {
	    return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code bool} field, including tag.
	   */
	  public static function computeBoolSize(fieldNumber:int, value:Boolean):int {
	    return computeTagSize(fieldNumber) + 1;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code string} field, including tag.
	   */
	  public static function computeStringSize(fieldNumber:int, value:String):int {

	    var bytes:ByteArray = new ByteArray();
	    bytes.writeUTFBytes(value);
	    return computeTagSize(fieldNumber) +
	           computeRawVarint32Size(bytes.length) +
	           bytes.length;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code group} field, including tag.
	   */
	  public static function computeGroupSize(fieldNumber:int, value:Message):int {
	    return computeTagSize(fieldNumber) * 2 + value.getSerializedSize();
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code group} field represented by an {@code UnknownFieldSet}, including
	   * tag.
	   */
	  /*public static function computeUnknownGroupSize(fieldNumber:int, value:UnknownFieldSet):int {
	    return computeTagSize(fieldNumber) * 2 + value.getSerializedSize();
	  }*/
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * embedded message field, including tag.
	   */
	  public static function computeMessageSize(fieldNumber:int, value:Message):int {
	    var size:int = value.getSerializedSize();
	    return computeTagSize(fieldNumber) + computeRawVarint32Size(size) + size;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code bytes} field, including tag.
	   */
	  public static function computeBytesSize(fieldNumber:int, value:ByteArray):int {
	  	var len:int = value.length;
	  	
	    return computeTagSize(fieldNumber) +
	           computeRawVarint32Size(len) + len;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * {@code uint32} field, including tag.
	   */
	  public static function computeUInt32Size(fieldNumber:int, value:int):int {
	    return computeTagSize(fieldNumber) + computeRawVarint32Size(value);
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * enum field, including tag.  Caller is responsible for converting the
	   * enum value to its numeric value.
	   */
	  public static function computeEnumSize(fieldNumber:int, value:int):int {
	    return computeTagSize(fieldNumber) + computeRawVarint32Size(value);
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * {@code sfixed32} field, including tag.
	   */
	  public static function computeSFixed32Size(fieldNumber:int, value:int):int {
	    return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * {@code sfixed64} field, including tag.
	   */
	  public static function computeSFixed64Size(fieldNumber:int, value:BigInteger):int {
	    return computeTagSize(fieldNumber) + LITTLE_ENDIAN_64_SIZE;
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * {@code sint32} field, including tag.
	   */
	  public static function computeSInt32Size(fieldNumber:int, value:int):int {
	    return computeTagSize(fieldNumber) +
	           computeRawVarint32Size(encodeZigZag32(value));
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * {@code sint64} field, including tag.
	   */
	  public static function computeSInt64Size(fieldNumber:int, value:BigInteger):int {
	    return computeTagSize(fieldNumber) +
	           computeRawVarint64Size(encodeZigZag64(value));
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a
	   * MessageSet extension to the stream.  For historical reasons,
	   * the wire format differs from normal fields.
	   */
	  public static function computeMessageSetExtensionSize(
	      fieldNumber:int, value:Message):int {
	    return computeTagSize(WireFormat.MESSAGE_SET_ITEM) * 2 +
	           computeUInt32Size(WireFormat.MESSAGE_SET_TYPE_ID, fieldNumber) +
	           computeMessageSize(WireFormat.MESSAGE_SET_MESSAGE, value);
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode an
	   * unparsed MessageSet extension field to the stream.  For
	   * historical reasons, the wire format differs from normal fields.
	   */
	  public static function computeRawMessageSetExtensionSize(
	      fieldNumber:int, value:String):int {
	    var bytesVal:ByteArray;
	    bytesVal.writeUTFBytes(value);
	    return computeTagSize(WireFormat.MESSAGE_SET_ITEM) * 2 +
	           computeUInt32Size(WireFormat.MESSAGE_SET_TYPE_ID, fieldNumber) +
	           computeBytesSize(WireFormat.MESSAGE_SET_MESSAGE, bytesVal);
	  }

	
	  // =================================================================
	
	
	  /** Write a single byte, represented by an integer value. */
	  public function writeRawByte(value:int):void {
	    output.writeByte(value);
	  }
	
	  /** Write an array of bytes. */
	  public function writeRawBytes(value:ByteArray):void {
	    writeRawBytesPartial(value, 0, value.length);
	  }
	
	  /** Write part of an array of bytes. */
	  public function writeRawBytesPartial(value:ByteArray, offset:int, length:int):void
	  {
	      output.writeBytes(value, offset, length);
	  }
	
	  /** Encode and write a tag. */
	  public function writeTag(fieldNumber:int, wireType:int):void {
	    writeRawVarint32(WireFormat.makeTag(fieldNumber, wireType));
	  }
	
	  /** Compute the number of bytes that would be needed to encode a tag. */
	  public static function computeTagSize(fieldNumber:int):int {
	    return computeRawVarint32Size(WireFormat.makeTag(fieldNumber, 0));
	  }
	
	  /**
	   * Encode and write a varint.  {@code value} is treated as
	   * unsigned, so it won't be sign-extended if negative.
	   */
	  public function writeRawVarint32(value:int):void {
	    while (true) {
	      if ((value & ~0x7F) == 0) {
	        writeRawByte(value);
	        return;
	      } else {
	        writeRawByte((value & 0x7F) | 0x80);
	        value >>>= 7;
	      }
	    }
	  }
	
	  /**
	   * Compute the number of bytes that would be needed to encode a varint.
	   * {@code value} is treated as unsigned, so it won't be sign-extended if
	   * negative.
	   */
	  public static function computeRawVarint32Size(value:int):int {
	    if ((value & (0xffffffff <<  7)) == 0) return 1;
	    if ((value & (0xffffffff << 14)) == 0) return 2;
	    if ((value & (0xffffffff << 21)) == 0) return 3;
	    if ((value & (0xffffffff << 28)) == 0) return 4;
	    return 5;
	  }
	
	  /** Encode and write a varint. */
	  public function writeRawVarint64(value:BigInteger):void {
	  	var ba:ByteArray = new ByteArray();
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0x80);
	  	ba.position = 0;
	  	var ff:BigInteger = new BigInteger(ba);
	  	
	    while (true) {
	      var b:int = value.byteValue();
	      if(value.and(ff).equals(BigInteger.ZERO)) {
	      	writeRawByte(b);
	        return;
	      }	else {
	      	writeRawByte((b & 0x7F) | 0x80);
	        value = value.shiftRight(7);
	      }
	    }
	  }
	
	  /** Compute the number of bytes that would be needed to encode a varint. */
	  public static function computeRawVarint64Size(value:BigInteger):int {
	  	var ba:ByteArray = new ByteArray();
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.writeByte(0xff);
	  	ba.position = 0;
	  	var ff:BigInteger = new BigInteger(ba);
	  	if(value.and(ff.shiftLeft(7)).equals(BigInteger.ZERO)) return 1;
	  	if(value.and(ff.shiftLeft(14)).equals(BigInteger.ZERO)) return 2;
	  	if(value.and(ff.shiftLeft(21)).equals(BigInteger.ZERO)) return 3;
	  	if(value.and(ff.shiftLeft(28)).equals(BigInteger.ZERO)) return 4;
	  	if(value.and(ff.shiftLeft(35)).equals(BigInteger.ZERO)) return 5;
	  	if(value.and(ff.shiftLeft(42)).equals(BigInteger.ZERO)) return 6;
	  	if(value.and(ff.shiftLeft(49)).equals(BigInteger.ZERO)) return 7;
	  	if(value.and(ff.shiftLeft(56)).equals(BigInteger.ZERO)) return 8;
	  	if(value.and(ff.shiftLeft(63)).equals(BigInteger.ZERO)) return 9;
	    return 10;
	  }
	
	  /** Write a little-endian 32-bit integer. */
	  public function writeRawLittleEndian32(value:int):void {
	    writeRawByte((value      ) & 0xFF);
	    writeRawByte((value >>  8) & 0xFF);
	    writeRawByte((value >> 16) & 0xFF);
	    writeRawByte((value >> 24) & 0xFF);
	  }
	
	  public static var LITTLE_ENDIAN_32_SIZE:int = 4;
	
	  /** Write a little-endian 64-bit integer. */
	  public function writeRawLittleEndian64(value:BigInteger):void {
	  	//tricky: BigInteger takes an array with heaviest byte first!
	  	//reverse from the stream

	  	var bytes:ByteArray = value.toByteArray();
	  	var b8:int = bytes.readByte();
	  	var b7:int = bytes.readByte();
	  	var b6:int = bytes.readByte();
	  	var b5:int = bytes.readByte();
	  	var b4:int = bytes.readByte();
	  	var b3:int = bytes.readByte();
	  	var b2:int = bytes.readByte();
	  	var b1:int = bytes.readByte();
	  	
	  	writeRawByte(b1);
	  	writeRawByte(b2);
	  	writeRawByte(b3);
	  	writeRawByte(b4);
	  	writeRawByte(b5);
	  	writeRawByte(b6);
	  	writeRawByte(b7);
	  	writeRawByte(b8);
	  }
	  
	  public static const LITTLE_ENDIAN_64_SIZE:int = 8;
	
	  /**
	   * Encode a ZigZag-encoded 32-bit value.  ZigZag encodes signed integers
	   * into values that can be efficiently encoded with varint.  (Otherwise,
	   * negative values must be sign-extended to 64 bits to be varint encoded,
	   * thus always taking 10 bytes on the wire.)
	   *
	   * @param n A signed 32-bit integer.
	   * @return An unsigned 32-bit integer, stored in a signed int because
	   *         Java has no explicit unsigned support.
	   */
	  public static function encodeZigZag32(n:int):int {
	    // Note:  the right-shift must be arithmetic
	    return (n << 1) ^ (n >> 31);
	  }
	
	  /**
	   * Encode a ZigZag-encoded 64-bit value.  ZigZag encodes signed integers
	   * into values that can be efficiently encoded with varint.  (Otherwise,
	   * negative values must be sign-extended to 64 bits to be varint encoded,
	   * thus always taking 10 bytes on the wire.)
	   *
	   * @param n A signed 64-bit integer.
	   * @return An unsigned 64-bit integer, stored in a signed int because
	   *         Java has no explicit unsigned support.
	   */
	  public static function encodeZigZag64(n:BigInteger):BigInteger {
	    // Note:  the right-shift must be arithmetic
	    var nA:BigInteger = n.shiftLeft(1);
	    var nB:BigInteger = n.shiftRight(63);
	    return nA.xor(nB);
	    //return (n << 1) ^ (n >> 63);
	  }
	}
}