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
    import com.adobe.net.URI;
    import com.mayerscraft.lang.E;
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.utilities.ErrorThrower;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 12:40
     */
    public class HTTPRequest implements IEventDispatcher 
    {
        private var _dispatcher  :EventDispatcher;
        
        internal var _frozen     :Boolean = false;
        internal var _response   :HTTPResponse;
        internal var _iteration  :int = 0;
        
        internal var _time       :Date;
        internal var _method     :String;
        internal var _request    :String;
        internal var _uri        :URI;
        internal var _proxy      :URI;
        internal var _headers    :Object;
        internal var _data       :*;
        internal var _encoded    :ByteArray;
        
        public function HTTPRequest(method:String, uri:String, headers:Object = null, data:Object = null) 
        {
            this.method = method;
            this.uri = uri;
            this.header(headers);
            this.data = data;
            
            _dispatcher = new EventDispatcher(this);
        }
        
        public function header(...args):*
        {
            _headers = _headers || { };
            
            switch (args.length)
            {
                case 0:
                {
                    return E.clone(_headers);
                }
                
                case 1:
                {
                    if (args[0] is HTTPHeader)
                    {
                        if (HTTPHeader.FORBIDDEN.indexOf(args[0]._name) == -1)
                        {
                            _headers[args[0]._name] = args[0];
                        }
                        else
                        {
                            ErrorThrower.throwParameterIsWrong(toString(), 
                                'header', EString.format("One cannot simply specify '{0}' header.", args[0]._name));
                        }
                    }
                    else if (args[0] is String)
                    {
                        return _headers[args[0]].clone();
                    }
                    else if (args[0] is Object)
                    {
                        for (var field:String in args[0]) 
                            header(field, args[0][field]);
                        return _headers;
                    }
                    break;
                }
                
                case 2:
                {
                    var name:String = String(args[0]);
                    var value:String = String(args[1]);
                    if (HTTPHeader.FORBIDDEN.indexOf(name) == -1)
                    {
                        _headers[name] = new HTTPHeader().parse(name + ': ' + value);
                    }
                    else
                    {
                        ErrorThrower.throwParameterIsWrong(toString(), 
                            'header', EString.format("One cannot simply specify '{0}' header.", name));
                    }
                    break;
                }
                
                default:
                {
                    ErrorThrower.throwWrongNumberOfArguments(toString(), 
                        'header', '0, 1 or 2', args.length.toString());
                    break;
                }
            }
            
            return null;
        }
        
        public function clone():HTTPRequest
        {
            var 
            request:HTTPRequest = new HTTPRequest(E.clone(_method), E.clone(_uri), null, _data);
            request._headers    = E.clone(_headers);
            request._time       = E.clone(_time);
            request._proxy      = E.clone(_proxy);
            request._encoded    = E.clone(_encoded);
            request._iteration  = E.clone(_iteration);
            return request;
        }
        
        public function toString(headers:Boolean = false):String
        {
            var result:String = EString.toString(this, 'HTTPRequest', 'method', 'uri', 'proxy');
            if (headers)
            {
                for (var name:String in _headers) 
                    result += '\n' + _headers[name].full();
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
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        
        public function get method():String 
        { 
            return _method; 
        }
        
        public function set method(value:String):void 
        { 
            if (!_frozen)
                _method = value; 
        }
        
        public function get uri():String 
        { 
            return _uri.toDisplayString(); 
        }
        
        public function set uri(value:String):void 
        { 
            if (!_frozen && value)
            {
                if (value.slice(0, 4) == 'http')
                    _uri = new URI(value); 
                else
                    _uri = new URI('http://' + value); 
            }
        }
        
        public function get proxy():String 
        { 
            return _proxy ? _proxy.toString() : null; 
        }
        
        public function set proxy(value:String):void 
        { 
            if (!_frozen && value)
            {
                if (value.slice(0, 4) == 'http')
                    _proxy = new URI(value); 
                else
                    _proxy = new URI('http://' + value);
            }
         }
        
        public function get headers():Object 
        { 
            return E.clone(_headers); 
        }
        
        public function get data():* 
        { 
            return E.clone(_data); 
        }
        
        public function set data(value:*):void 
        { 
            if (!_frozen)
                _data = value; 
        }
    }
}