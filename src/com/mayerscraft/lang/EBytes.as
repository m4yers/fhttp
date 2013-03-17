/*
 * Copyright (c) 2013 Artyom Goncharov
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package com.mayerscraft.lang 
{
    import flash.utils.ByteArray;
    /**
     * 
     * @author Artyom Goncharov 28.02.2013 12:36
     */
    public class EBytes extends ByteArray
    {
        public static const CR:int = 13;    // caret return
        public static const LF:int = 10;    // linefeed
        
        /**
         * 
         * @param bytes
         * @return
         */
        public static function clone(bytes:ByteArray):ByteArray
        {
            var 
            result:ByteArray = new ByteArray;
            result.writeBytes(bytes, 0, 0);
            result.position = bytes.position;
            
            return result;
        }
        
        /**
         * The method converts passed data into ByteArray.
         * 
         * NOTE. There is no fromByteArrayMethod, because the method DO NOT 
         * serializes the data by means of some algorithm, you cannot get the 
         * converted data back to its original state. You SHOULD NOT use this 
         * method with complex objects such as Date. Simple Object instances 
         * will marshalized as JSON and then serialized as String. Primitive 
         * types serialized as is.
         * 
         * @param data  Any data to be translated into ByteArray
         * @return Returns new ByteArray object of specified data.
         */
        public static function toBytes(data:*):ByteArray
        {
            if (data is ByteArray)
            {
                return clone(data);
            }
            else if ('toBytes' in data && data.toBytes is Function)
            {
                try
                {
                    return data.toBytes();
                }
                catch (e:Error)
                {
                }
            }
            
            var bytes:ByteArray = new ByteArray;
            
            if (data is Number)
                bytes.writeDouble(data);
            else if (data is uint)
                bytes.writeUnsignedInt(data);
            else if (data is int)
                bytes.writeInt(data);
            else if (data is String)
                bytes.writeUTFBytes(data);
            else if (data is Object)
                bytes.writeUTFBytes(JSON.stringify(data));
            
            return bytes;
        }
        
        public static function toChars(bytes:ByteArray):Vector.<uint>
        {
            var result:Vector.<uint> = new Vector.<uint>;
            
            if (bytes)
            {
                var position:uint = bytes.position;
                bytes.position = 0;
                while (bytes.bytesAvailable)
                    result.push(bytes.readUnsignedByte());
                bytes.position = position;
            }
            
            return result;
        }
        
        public static function isNext(bytes:ByteArray, ...chars):Boolean 
        {
            var position:uint = bytes.position;
            if (bytes.bytesAvailable >= chars.length)
            {
                for (var i:uint = 0; i < chars.length; i++) 
                {
                    if (bytes.readByte() != int(chars[i]))
                    {
                        bytes.position = position;
                        return false;
                    }
                }
                bytes.position = position;
                return true;
            }
            
            bytes.position = position;
            return false;
        }
        
        public static function read(from:ByteArray, to:ByteArray = null, bound:Array = null):ByteArray
        {
            to = to || new ByteArray;
            bound = bound || [];
            
            var args:Array = [ from ].concat(bound);
            while (from.bytesAvailable > 0)
            {
                if (isNext.apply(null, args))        // found the bound
                {
                    from.position += bound.length;    // move to the bound end
                    break;
                }
                else
                {
                    to.writeByte(from.readByte());    // write currect byte
                }
            }
            to.position = 0;
            return to;
        }
        
        public static function readLine(from:ByteArray):ByteArray
        {
            return read(from, new ByteArray, [ CR, LF ]);
        }
        
        public static function readBody(from:ByteArray, to:ByteArray = null, length:uint = 0):ByteArray
        {
            to = to || new ByteArray;
            length = length == 0 ? from.length : length;
            
            var size:uint = from.bytesAvailable < length ? from.bytesAvailable : length;
            from.readBytes(to, to.position, size)
            to.position += size;
            return to;
        }
        
        public static function readChunk(from:ByteArray, to:ByteArray):Boolean
        {
            if (to.bytesAvailable == 0)
            {
                var line:ByteArray = readLine(from);
                if (line.length != 0)
                {
                    var string:String = line.toString();
                    if (EString.isHex(string))
                    {
                        var length:uint = uint('0x' + line.toString());
                        to.length += length;
                        
                        if (length == 0)
                        {
                            from.position += 4;
                            return true;
                        }
                    }
                }
                return false;
            }
            
            readBody(from, to, to.bytesAvailable);
            if (to.bytesAvailable == 0)                                                    // whether have read full chunk
                from.position += from.bytesAvailable > 1 ? 2 : from.bytesAvailable;        // drop CRLF if any
                
            return false;
        }
        
        public function EBytes()
        {
        }
        
        public function clone():ByteArray
        {
            return EBytes.clone(this);
        }
        
        /**
         * The method converts passed data into ByteArray.
         * 
         * NOTE. There is no fromByteArrayMethod, because the method DO NOT 
         * serializes the data by means of some algorithm, you cannot get the 
         * converted data back to its original state. You SHOULD NOT use this 
         * method with complex objects such as Date. Simple Object instances 
         * will marshalized as JSON and then serialized as String. Primitive 
         * types serialized as is.
         * 
         * @param data  Any data to be translated into ByteArray
         * @return Returns new ByteArray object of specified data.
         */
        public function toBytes():void
        {
            readBytes(EBytes.toBytes(this));
        }
        
        public function toChars():Vector.<uint>
        {
            return EBytes.toChars(this);
        }
        
        public function isNext(bytes:ByteArray, ...chars):Boolean 
        {
            return EBytes.isNext.apply(null, chars);
        }
        
        public function read(to:ByteArray = null, bound:Array = null):ByteArray
        {
            return EBytes.read(this, to, bound);
        }
        
        public function readLine():ByteArray
        {
            return EBytes.readLine(this);
        }
        
        public function readBody(to:ByteArray = null, length:uint = 0):ByteArray
        {
            return EBytes.readBody(this, to, length);
        }
        
        public function readChunk(to:ByteArray):Boolean
        {
            return EBytes.readChunk(this, to);
        }
    }
}