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
	import flash.errors.IOError;
	
	/**
	 * Thrown when a protocol message being parsed is invalid in some way,
	 * e.g. it contains a malformed varint or a negative byte length.
	 *
	 * @author Robert Blackwood
	 * -ported from kenton's java implementation
	 */
	public class InvalidProtocolBufferException extends IOError 
	{
	  public function InvalidProtocolBufferException(description:String) 
	  {
	    super(description);
	  }
	  
	  public static function truncatedMessage():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "While parsing a protocol message, the input ended unexpectedly " +
	      "in the middle of a field.  This could mean either than the " +
	      "input has been truncated or that an embedded message " +
	      "misreported its own length.");
	  }
	
	 public  static function negativeSize(): InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "CodedInputStream encountered an embedded string or message " +
	      "which claimed to have negative size.");
	  }
	
	  public static function malformedVarint():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "CodedInputStream encountered a malformed varint.");
	  }
	
	  public static function invalidTag():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "Protocol message contained an invalid tag (zero).");
	  }
	
	  public static function invalidEndTag():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "Protocol message end-group tag did not match expected tag.");
	  }
	
	  public static function invalidWireType():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "Protocol message tag had invalid wire type.");
	  }
	
	  public static function recursionLimitExceeded():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "Protocol message had too many levels of nesting.  May be malicious.  " +
	      "Use CodedInputStream.setRecursionLimit() to increase the depth limit.");
	  }
	
	  public static function sizeLimitExceeded():InvalidProtocolBufferException {
	    return new InvalidProtocolBufferException(
	      "Protocol message was too large.  May be malicious.  " +
	      "Use CodedInputStream.setSizeLimit() to increase the size limit.");
	  }
	}
}