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
package com.mayerscraft.mime 
{
    import com.mayerscraft.http.HTTPHeader;
    import com.mayerscraft.lang.EBytes;
    import com.mayerscraft.lang.EString;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 25.02.2013 17:57
     */
    public class MIMEMultipart extends MIMEObject
    {
        private var _boundary:String;
        
        public function MIMEMultipart(subtype:String = 'mixed') 
        {
            super('multipart/' + subtype, { boundary: _boundary = bound() }, new Vector.<IMIMEObject>);
        }
        
        public function add(object:IMIMEObject, options:Object = null):MIMEMultipart
        {
            if (_data.indexOf(object) == -1)
                _data.push(object);
            return this;
        }
        
        override public function encode():ByteArray
        {
            var bytes:ByteArray = new ByteArray;
            
            for (var i:int = 0; i < _data.length; i++) 
            {
                var object:IMIMEObject = _data[i];
                bytes.writeByte(HY);
                bytes.writeByte(HY);
                bytes.writeMultiByte(boundary, CHARSET_US_ASCII);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
                
                for each (var header:HTTPHeader in object.headers) 
                {
                    bytes.writeMultiByte(header.full(), CHARSET_US_ASCII);
                    bytes.writeByte(CR);
                    bytes.writeByte(LF);
                }
                
                bytes.writeByte(CR);
                bytes.writeByte(LF);
                bytes.writeBytes(object.encode(), 0, 0);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
            }
            
            bytes.writeByte(HY);
            bytes.writeByte(HY);
            bytes.writeMultiByte(boundary, CHARSET_US_ASCII);
            bytes.writeByte(HY);
            bytes.writeByte(HY);
            
            return bytes;
        }
        
        override public function decode(bytes:ByteArray):IMIMEObject
        {
            _data = new Vector.<IMIMEObject>;
            
            var headers:Object = { };
            var delimiter:String;
            var data:ByteArray;
            var line:ByteArray;
            
            bytes.position = 0;
            line = EBytes.readLine(bytes);
            if (line.readByte() == HY && line.readByte() == HY)
            {
                delimiter = EString.trim(line.toString());
                while (bytes.bytesAvailable != 0)
                {
                    line = EBytes.readLine(bytes);
                    if (line.length == 0)    //next is data
                    {
                        data = new ByteArray;
                        while (true && bytes.bytesAvailable != 0) 
                        {
                            line = EBytes.readLine(bytes);
                            if (line.toString().indexOf(delimiter) == -1)
                            {
                                data.writeBytes(line, 0, 0);
                            }
                            else
                            {
                                _data.push(MIME.decode(data, 'text/plain'));
                                break;
                            }
                        }
                    }
                    else
                    {
                        var header:HTTPHeader = new HTTPHeader().parse(line.toString());
                        headers[header.name()] = header;
                    }
                }
            }
            else
            {
                throw new Error('Not multipart format');
            }
            
            return this;
        }
        
        override public function toString():String
        {
            return encode().toString();
        }
        
        private function bound(length:int = 32):String
        {
            if (length < 5)
                length = 5;
            
            if (length > 70)
                length = 70;
            
            var result:String = '';
            
            for (var j:int = 0; j < length; j++) 
                result += int(Math.random() * 16).toString(16);
                
            return result;
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        
        public function get boundary():String 
        { 
            return _boundary; 
        }
    }
}