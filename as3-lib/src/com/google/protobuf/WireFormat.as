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
	/**
	 * WireFormat provides a static object from which to retrieve
	 * important encoding information regarding a particular tag.
	 * 
	 * Used primarily in the CodedInputStream and the 
	 * CodedOutputStream; it really should not be needed oustide
	 * of these clases.
	 * 
	 * @author Robert Blackwood
	 */
	public final class WireFormat 
	{
	  // Do not allow instantiation.
	
	  static public const WIRETYPE_VARINT:int           = 0;
	  static public const WIRETYPE_FIXED64:int          = 1;
	  static public const WIRETYPE_LENGTH_DELIMITED:int = 2;
	  static public const WIRETYPE_START_GROUP:int      = 3;
	  static public const WIRETYPE_END_GROUP:int        = 4;
	  static public const WIRETYPE_FIXED32:int          = 5;
	
	  static public const TAG_TYPE_BITS:int = 3;
	  static public const TAG_TYPE_MASK:int = (1 << TAG_TYPE_BITS) - 1;
	
	  /** Given a tag value, determines the wire type (the lower 3 bits). */
	  public static function getTagWireType(tag:int):int {
	    return tag & TAG_TYPE_MASK;
	  }
	
	  /** Given a tag value, determines the field number (the upper 29 bits). */
	  public static function getTagFieldNumber(tag:int):int {
	    return tag >>> TAG_TYPE_BITS;
	  }
	
	  /** Makes a tag value given a field number and wire type. */
	  public static function makeTag(fieldNumber:int, wireType:int):int {
	    return (fieldNumber << TAG_TYPE_BITS) | wireType;
	  }
	
	  // Field numbers for fields in MessageSet wire format.
	  public static const MESSAGE_SET_ITEM:int    = 1;
	  public static const MESSAGE_SET_TYPE_ID:int = 2;
	  public static const MESSAGE_SET_MESSAGE:int = 3;
	
	  // Tag numbers.
	  public static const MESSAGE_SET_ITEM_TAG:int =
	    makeTag(MESSAGE_SET_ITEM, WIRETYPE_START_GROUP);
	  public static const MESSAGE_SET_ITEM_END_TAG:int =
	    makeTag(MESSAGE_SET_ITEM, WIRETYPE_END_GROUP);
	  public static const MESSAGE_SET_TYPE_ID_TAG:int =
	    makeTag(MESSAGE_SET_TYPE_ID, WIRETYPE_VARINT);
	  public static const MESSAGE_SET_MESSAGE_TAG:int =
	    makeTag(MESSAGE_SET_MESSAGE, WIRETYPE_LENGTH_DELIMITED);
	}
}