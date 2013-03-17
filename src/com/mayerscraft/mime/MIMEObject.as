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
    import com.mayerscraft.lang.E;
    import com.mayerscraft.lang.EBytes;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 25.02.2013 17:57
     */
    internal class MIMEObject implements IMIMEObject
    {
        protected static const CHARSET_US_ASCII   :String = 'us-ascii';
        protected static const CHARSET_UTF_8     :String = 'utf-8';
        protected static const CR                :int = 13;    // caret return
        protected static const LF                :int = 10;    // linefeed
        protected static const HY                :int = 45;    // hyphen
        
        internal var _type      :String;
        internal var _headers   :Object;
        internal var _data      :*;
        
        public function MIMEObject(type:String, options:Object = null, data:* = null) 
        {
            _type = type;
            _data = data;
            
            _headers = { };
            _headers[HTTPHeader.CONTENT_TYPE] = new HTTPHeader(HTTPHeader.CONTENT_TYPE, _type, null, options);
        }
        
        public function encode():ByteArray
        {
            return EBytes.toBytes(_data);
        }
        
        public function decode(bytes:ByteArray):IMIMEObject
        {
            _data = bytes.toString();
            return this;
        }
        
        public function toString():String
        {
            return String(_data);
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        
        public function get type():String 
        { 
            return _type; 
        }
        
        public function get headers():Object 
        { 
            return E.clone(_headers); 
        }
        
        public function get data():* 
        { 
            return _data; 
        }
    }
}