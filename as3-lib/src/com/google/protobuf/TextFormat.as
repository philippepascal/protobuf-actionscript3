package com.google.protobuf
{
	import flash.utils.getDefinitionByName;
	
	
	/**
	 * A limited set of the original java implementation. To Be Completed
	 * 
	 * @author Philippe Pascal 
	 */
	public class TextFormat
	{
		public static const underscorePattern:RegExp = /_([a-z])/g;
		public const fieldPattern:RegExp = /(\w(\w|[-\.])*):\s(.+)$/gm;
		public const messagePattern:RegExp = /(\w(\w|[-\.])*)\s\{([^\}]+)\}/g; //gms
		
		public function TextFormat()
		{
		}

		public function merge(gpbMessage:Message,text:String):void {
			//trace("### merge "+gpbMessage);
			var matchedMessages:Array = new Array();
			var matchedFields:Array = new Array();
			//1 match the messages.
			var matchMessage:Array = messagePattern.exec(text);
			while(matchMessage != null) {
				matchedMessages.push(matchMessage);
				matchMessage = messagePattern.exec(text);
			}
			for each(var matchedMessage:Array in matchedMessages) {
				var fieldName:String = morphGPBNameToMessageName(matchedMessage[1]);
				//trace("message: "+matchedMessage[1]+" ,fieldName: "+fieldName+" ,value: "+matchedMessage[3]);
				var descriptor:Descriptor = gpbMessage.getDescriptor(fieldName);
				var classRef:Class = getDefinitionByName(descriptor.messageClass) as Class;
				var embeddedMessage:Message = new classRef() as Message;
				merge(embeddedMessage,matchedMessage[3]);
				(gpbMessage[fieldName] as Array).push(embeddedMessage);
			}
			//2 remove the messages from the text
			messagePattern.lastIndex=0;
			var textWOMessage:String = text.replace(messagePattern,"");
			//3 match the fields
			var matchField:Array = fieldPattern.exec(textWOMessage);
			while(matchField != null) {
				matchedFields.push(matchField);
				matchField = fieldPattern.exec(textWOMessage);
			}
			for each(var matchedField:Array in matchedFields) {
				fieldName = morphGPBNameToMessageName(matchedField[1]);
				//trace("field: "+matchedField[1]+" ,fieldName: "+fieldName+" ,value: "+matchedField[3]);
				descriptor = gpbMessage.getDescriptor(fieldName);
				gpbMessage[fieldName] = parseValue(descriptor.type,matchedField[3]);
			}
			//
			//trace("### done merging "+gpbMessage);
		}
		
		public function parseValue(type:int,value:String):Object {
			switch(type) {
//		      case Descriptor.DOUBLE  : return readDouble  ();
//		      case Descriptor.FLOAT   : return readFloat   ();
//		      case Descriptor.INT64   : return readInt64   ();
//		      case Descriptor.UINT64  : return readUInt64  ();
//		      case Descriptor.INT32   : return readInt32   ();
//		      case Descriptor.FIXED64 : return readFixed64 ();
//		      case Descriptor.FIXED32 : return readFixed32 ();
		      case Descriptor.BOOL    : return readBool    (value);
		      case Descriptor.STRING  : return readString  (value);
//		      case Descriptor.BYTES   : return readBytes   ();
//		      case Descriptor.UINT32  : return readUInt32  ();
//		      case Descriptor.SFIXED32: return readSFixed32();
//		      case Descriptor.SFIXED64: return readSFixed64();
//		      case Descriptor.SINT32  : return readSInt32  ();
//		      case Descriptor.SINT64  : return readSInt64  ();
			  case Descriptor.ENUM    : return readEnum    (value);
			  default: return null;
			}
		}
		public function readBool(value:String):Boolean {
			return value.indexOf("true")==0;
		}
		public function readString(value:String):String {
			return value.substring(1,value.length-1);
		}
		//PLACEHOLDER -- TODO
		public function readEnum(value:String):int {
			return 1;
		}
		
		/**
		 * for some reasone (GPB or existing AS code), field names are transformed between
		 * the proto files and the actionscript class message. This needs to be consistent 
		 * text format.
		 */
		public static function morphGPBNameToMessageName(fieldName:String):String {
			return fieldName.replace(underscorePattern,lowerCase);
		}
		public static function lowerCase(matchedSubstring:String,
		                                 capturedMatch1:String,
		                                 index:int,
		                                 str:String):String
		{
		 	return capturedMatch1.toUpperCase();                      	
		}
	}
}