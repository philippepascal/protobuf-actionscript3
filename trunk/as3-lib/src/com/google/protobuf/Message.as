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
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getDefinitionByName;
	
	/**
	 * This would be better if it were abstract, then we could create
	 * an interface and move fieldDescriptors into the actual message 
	 * implementation and make it static (more efficient)
	 *
	 * @author Robert Blackwood
	 */
	public class Message {
	
	  protected var fieldDescriptors:Array;
	  
	  //Intialize our field descriptors
	  public function Message() {
	  	if (fieldDescriptors == null)
		  	fieldDescriptors = new Array();	
	  }
	  
	  public function writeToCodedStream(output:CodedOutputStream ):void {
	  	
        for each (var desc:Descriptor in fieldDescriptors) 
        {
		
        	//Don't write it if it is null
			if (this[desc.fieldName] == null)
			{  
				if( desc.isRequired())
					trace("Missing required field " + desc.fieldName);
			}
			else
			{	
				//We have an array, write it out
				if (desc.isRepeated() && this[desc.fieldName] is Array)
				{
					for each( var elem:* in this[desc.fieldName])
					{
						//If its a message, recurse this function, else just write out the primative
						if (desc.isMessage())
						{
							//write out the size first
//							output.writeRawVarint32(elem.getSerializedSize())
//							elem.writeToCodedStream(output);
							output.writeMessage(desc.fieldNumber, elem);
						}
						else //primative
							output.writeField(desc.fieldNumber, elem);
					}
				}
				else 
				{
					//Message/primative thats not repeated
					if (desc.isMessage())
					{
						if ( this[desc.fieldName] is Message )
							output.writeMessage(desc.fieldNumber, this[desc.fieldName]);
					}
					else //primative
						output.writeField(desc.fieldNumber, this[desc.fieldName]);
				}
			}
        }
      }
	
	  public function writeToDataOutput(output:IDataOutput):void {
	    var codedOutput:CodedOutputStream = CodedOutputStream.newInstance(output);
	    writeToCodedStream(codedOutput);
	  }
	 
	  public function readFromCodedStream(input:CodedInputStream):void {
	
		//Get the first tag
	  	var tag:int = input.readTag();
	  	
	  	//Loop thru everything we get
	  	while (tag != 0)
	  	{
	  		//Grab our info from the tag
	  		var fieldNum:int = WireFormat.getTagFieldNumber(tag);
	  		var desc:Descriptor = getDescriptorByFieldNumber(fieldNum);
	  		
	  		if (desc != null)
	  		{
	  			//The item can be any type
	  			var item:*;
	  			
	  			//If we have a message, recurse this function to read it in
	  			if (desc.isMessage())
	  			{
	  				//Introspect to get message's type, then read it in
	  				//Inserting the package here is a little ugly......
	  				var classRef:Class = getDefinitionByName(desc.messageClass) as Class;
					item = new classRef();
					
					//Read whole message to ByteArray (not the best, too slow but easy)
					var size:int = input.readRawVarint32();
					var bytes:ByteArray = input.readRawBytes(size);
			  		//fix bug 1 protobuf-actionscript3
					bytes.position = 0;
					item.readFromDataOutput(bytes);
	  			}
	  			//Just a primative type, read it in
	  			else
		  			item = input.readPrimitiveField(desc.type);
	  			
	  			//We have an array, push item to the array
	  			if (desc.isRepeated() && this[desc.fieldName] is Array)
					this[desc.fieldName].push(item); //Concatenation automatically happens if duplicate
				else
		  			this[desc.fieldName] = item; //just set it (official pb requires merging here, in the case of duplicates)		
	  		}
	  		else
	  			input.skipField(tag); //Throw it away, we don't have that version
	  			
	  		//Read the next tag in stream
	  		tag = input.readTag();	
	  	}
	  }
	
	  /** 
	  * Wrapper for readFromCodedStream, take something coforming to
	  * the IDataInput interface and construct a coded stream from it
	  */
	  public function readFromDataOutput(input:IDataInput):void {
	    var codedInput:CodedInputStream = CodedInputStream.newInstance(input);
	    
	    readFromCodedStream(codedInput);
	  }
	  
	  /**
	  * When writing a message field, it is length delimited, therefore
	  * we must know it's exact size before we write it, this function
	  * uses the output stream to determine the correct size
	  */
	  public function getSerializedSize():int {
	  	
	  	var size:int = 0;
	  	
	    for each (var desc:Descriptor in fieldDescriptors) 
	    {
	    	//Ignore null fields.. cause we won't write them!
	    	if (this[desc.fieldName] != null)
				size += CodedOutputStream.computeFieldSize( desc.fieldNumber, this[desc.fieldName]);
		} 
		
		return size;
	  }
	  
	  /**
	  * All subclasses must register the fields they want visible to
	  * protocol buffers. The protoc executable will take care of
	  * registering fields for you.
	  */
	  protected function registerField(field:String, messageClass:String, type:int, label:int, fieldNumber:int):void {

		//register descriptors only once	  	
	  	if (fieldDescriptors[field] == null)
		  	fieldDescriptors[field] = new Descriptor(field, messageClass, type, label, fieldNumber);
	  }
	  
	  /**
	  * Convenience method for getting a descriptor by field number
	  */
	  public function getDescriptorByFieldNumber(fieldNum:int):Descriptor {
	  	for each ( var desc:Descriptor in fieldDescriptors ) {
	  		if (desc.fieldNumber == fieldNum)
	  			return desc;
	  	}
	  	return null;
	  }
	  
	  /**
	  * fieldDescriptors is an associative array that uses the field's
	  * name as an index for retrieving a descriptor. This function
	  * is just a more descriptive way of indexing the array.
	  */
	  public function getDescriptor(field:String):Descriptor {
		 	return fieldDescriptors[field];
	  }
	  
	  // =================================================================
	}
}