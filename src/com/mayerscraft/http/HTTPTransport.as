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
package com.mayerscraft.http 
{
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 26.12.2012 17:20
     */
    public class HTTPTransport 
    {
        public static const IDENTITY   :String = 'identity';
        public static const CHUNKED    :String = 'chunked';
        
        private static const CHARSET   :String = 'us-ascii';
        private static const CR        :int = 13;    // caret return
        private static const LF        :int = 10;    // linefeed
        private static const HY        :int = 45;    // hyphen
        
        public static function to(request:HTTPRequest):HTTPRequest
        {
            switch (request._headers[HTTPHeader.CONTENT_ENCODING])
            {
                case HTTPEncoding.TYPE_GZIP:
                {
                    var bytes:ByteArray = new ByteArray;
                    var source:ByteArray = request._encoded;
            
                    source.position = 0;
                    while (source.bytesAvailable > 0)
                    {
                        var size:uint = source.bytesAvailable;
                        bytes.writeMultiByte(size.toString(16), CHARSET);
                        bytes.writeByte(CR);
                        bytes.writeByte(LF);
                        source.readBytes(bytes, bytes.length, size);
                        bytes.position = bytes.length;
                        bytes.writeByte(CR);
                        bytes.writeByte(LF);
                    }
                    
                    bytes.writeByte(48);
                    bytes.writeByte(CR);
                    bytes.writeByte(LF);
                    bytes.writeByte(CR);
                    bytes.writeByte(LF);
                    bytes.position = 0;
                    
                    request._encoded = bytes;
                    request._headers[HTTPHeader.TRANSFER_ENCODING] 
                        = new HTTPHeader(HTTPHeader.TRANSFER_ENCODING, HTTPTransport.CHUNKED);
                    break;
                }
            }
            
            return request
        }
        
        public static function from():void
        {
        }
    }
}