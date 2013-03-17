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
    import com.mayerscraft.lang.E;
    import com.mayerscraft.lang.EBytes;
    import com.mayerscraft.lang.EString;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 14:15
     */
    public class HTTPResponse implements IEventDispatcher
    {
        public static const STATE_NONE      :int = -1;
        public static const STATE_STATUS    :int =  0;
        public static const STATE_HEADERS   :int =  1;
        public static const STATE_DATA      :int =  2;
        public static const STATE_COMPLETE  :int =  3;
        
        private var _dispatcher :EventDispatcher;
        
        internal var _state     :int;
        internal var _time      :Date;
        internal var _request   :HTTPRequest;
        internal var _previous  :HTTPResponse;
        internal var _message   :ByteArray;
        
        internal var _version   :Number;
        internal var _code      :int;
        internal var _phrase    :String;
        internal var _headers   :Object;
        internal var _encoded   :ByteArray;    // encoded data
        internal var _data      :*;            // decoded data
    
    //----------------------------------
    //  interface
    //----------------------------------
        public function HTTPResponse() 
        {
            _dispatcher = new EventDispatcher(this);
            identify();
        }
        
        public function header(name:String):String
        {
            if (name in _headers)
                return _headers[name].clone();
                
            return '';
        }
        
        public function clone():HTTPResponse
        {
            var 
            response:HTTPResponse  = new HTTPResponse();
            response._time         = E.clone(_time);
            response._version      = E.clone(_version);
            response._code         = E.clone(_code);
            response._phrase       = E.clone(_phrase);
            response._headers      = E.clone(_headers);
            response._data         = E.clone(_data);
            return response;
        }
        
        public function toString(headers:Boolean = false):String
        {
            var result:String = EString.toString(this, 'HTTPResponse', 'version', 'code', 'phrase');
            if (headers)
            {
                for (var name:String in _headers) 
                    result += '\n' + _headers[name].toString();
            }
            return result;
        }
        
    //----------------------------------
    //  delegates
    //----------------------------------
        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
        {
            _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public function dispatchEvent(event:Event):Boolean 
        {
            return _dispatcher.dispatchEvent(event);
        }
        
        public function hasEventListener(type:String):Boolean 
        {
            return _dispatcher.hasEventListener(type);
        }
        
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
        {
            _dispatcher.removeEventListener(type, listener, useCapture);
        }
        
        public function willTrigger(type:String):Boolean 
        {
            return _dispatcher.willTrigger(type);
        }
        
    //----------------------------------
    //  internal
    //----------------------------------
        internal function identify(response:HTTPResponse = null):void
        {
            if (response)
            {
                _time       = response._time;
                _state      = response._state;
                _message    = response._message;
                _version    = response._version;
                _code       = response._code;
                _phrase     = response._phrase;
                _headers    = response._headers;
                _data       = response._data;
                _encoded    = response._encoded;
            }
            else
            {
                _time       = null;
                _state      = STATE_NONE;
                _message    = new ByteArray;
                _version    = NaN;
                _code       = 000;
                _phrase     = null;
                _data       = null;
                _encoded    = null;
                _headers    = { };
            }
        }
        
        internal function serialize():ByteArray
        {
            var 
            bytes:ByteArray = new ByteArray;
            bytes.writeUnsignedInt(int(_time.time));
            bytes.writeByte(_version * 10);
            bytes.writeUnsignedInt(_code);
            bytes.writeUnsignedInt(_phrase.length);
            bytes.writeMultiByte(_phrase, 'us-ascii');
            for each (var header:HTTPHeader in _headers) 
            {
                var full:String = header.full();
                bytes.writeUnsignedInt(full.length);
                bytes.writeMultiByte(full, 'us-ascii');
            }
            bytes.writeUnsignedInt(0);
            if (_encoded)
            {
                bytes.writeUnsignedInt(_encoded.length);
                bytes.writeBytes(_encoded);
            }
            else
            {
                bytes.writeUnsignedInt(0);
            }
            
            return bytes;
        }
        
        internal function deserialize(bytes:ByteArray):void
        {
            if (bytes)
            {
                bytes.position = 0;
                
                _time = _time || new Date;
                _time.setTime(bytes.readUnsignedInt());
                _version = bytes.readUnsignedByte() / 10;
                _code = bytes.readUnsignedInt();
                var plength:int = bytes.readUnsignedInt();
                _phrase = bytes.readMultiByte(plength, 'us-ascii');
                _headers = _headers || { };
                while (bytes.bytesAvailable && bytes.readUnsignedInt() != 0)
                {
                    bytes.position-=4;
                    var hlength:int = bytes.readUnsignedInt();
                    var hraw:String = bytes.readMultiByte(hlength, 'us-ascii');
                    var header:HTTPHeader = new HTTPHeader();
                    header.parse(hraw);
                    _headers[header.name()] = header
                }
                
                var elength:int = bytes.readUnsignedInt();
                if (elength)
                {
                    _encoded = EBytes.readBody(bytes, null, elength);
                    HTTPEncoding.decode(this);
                    HTTPContent.decode(this);
                }
            }
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        
        public function get version():Number 
        { 
            return _version; 
        }
        
        public function get code():int 
        { 
            return _code; 
        }
        
        public function get phrase():String 
        { 
            return _phrase; 
        }
        
        public function get data():* 
        { 
            return _data; 
        }
        
        public function get previous():HTTPResponse 
        { 
            return _previous; 
        }
    }
}