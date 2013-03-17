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
    import com.mayerscraft.lang.EString;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 15:11
     */
    public class HTTPHeader 
    {
    //----------------------------------
    //  general
    //----------------------------------
        public static const CACHE_CONTROL           :String = 'cache-control';
        public static const CONNECTION              :String = 'connection';
        public static const KEEP_ALIVE              :String = 'keep-alive';
        public static const DATE                    :String = 'date';
        public static const PRAGMA                  :String = 'pragma';
        public static const TRAILER                 :String = 'trailer';
        public static const TRANSFER_ENCODING       :String = 'transfer-encoding';
        public static const UPGRADE                 :String = 'upgrade';
        public static const VIA                     :String = 'via';
        public static const WARNING                 :String = 'warning';
        public static const PROXY_CONNECTION        :String = 'proxy-connection';
        
    //----------------------------------
    //  request
    //----------------------------------
        public static const ACCEPT                  :String = 'accept';
        public static const ACCEPT_CHARSET          :String = 'accept-charset';
        public static const ACCEPT_ENCODING         :String = 'accept-encoding';
        public static const ACCEPT_LANGUAGE         :String = 'accept-language';
        public static const AUTHORIZATION           :String = 'authorization';
        public static const COOKIE                  :String = 'cookie';
        public static const EXPECT                  :String = 'expect';
        public static const FROM                    :String = 'from';
        public static const HOST                    :String = 'host';
        public static const IF_MATCH                :String = 'if-match';
        public static const IF_MODIFIED_SINCE       :String = 'if-modified-since';
        public static const IF_NONE_MATCH           :String = 'if-none-match';
        public static const IF_RANGE                :String = 'if-range';
        public static const IF_UNMODIFIED_SINCE     :String = 'if-unmodified-since';
        public static const MAX_FORWARDS            :String = 'max-forwards';
        public static const PROXY_AUTHORIZATION     :String = 'proxy-authorization';
        public static const RANGE                   :String = 'range';
        public static const REFERER                 :String = 'referer';
        public static const TE                      :String = 'te';
        public static const USER_AGENT              :String = 'user-agent';
        
    //----------------------------------
    //  response
    //----------------------------------
        public static const ACCEPT_RANGES           :String = 'accept-ranges';
        public static const AGE                     :String = 'age';
        public static const ETAG                    :String = 'etag';
        public static const LOCATION                :String = 'location';
        public static const PROXY_AUTHENTICATE      :String = 'proxy-authenticate';
        public static const RETRY_AFTER             :String = 'retry-after';
        public static const SERVER                  :String = 'server';
        public static const SET_COOKIE              :String = 'set-cookie';
        public static const VARY                    :String = 'vary';
        public static const WWW_AUTHENTICATE        :String = 'www-authenticate';

    //----------------------------------
    //  entity
    //----------------------------------
        public static const ALLOW                   :String = 'allow';
        public static const CONTENT_DISPOSITION     :String = 'content-disposition';
        public static const CONTENT_ENCODING        :String = 'content-encoding';
        public static const CONTENT_LANGUAGE        :String = 'content-language';
        public static const CONTENT_LENGTH          :String = 'content-length';
        public static const CONTENT_LOCATION        :String = 'content-location';
        public static const CONTENT_MD5             :String = 'content-md5';
        public static const CONTENT_RANGE           :String = 'content-range';
        public static const CONTENT_TYPE            :String = 'content-type';
        public static const EXPIRES                 :String = 'expires';
        public static const LAST_MODIFIED           :String = 'last-modified';
        
    //----------------------------------
    //  restricted
    //----------------------------------
        internal static const FORBIDDEN:Array = 
        [
            ACCEPT_ENCODING,
            CONNECTION,
            CONTENT_ENCODING,
            CONTENT_LENGTH,
            EXPECT,
            HOST,
            TRANSFER_ENCODING,
            TE
        ];
        
        internal static const UNBREAKABLE:Array = 
        [
            DATE,
            EXPIRES,
            LAST_MODIFIED
        ];
        
        internal var _name   :String;
        internal var _values :Object = { };
        
        public function HTTPHeader(name:String = null, token:String = null, value:String = null, parameters:Object = null):void
        {
            _name = name ? EString.trim(name.toLowerCase()) : 'header';
            if (token) 
                _values[token] = new HTTPHeaderValue(EString.trim(token), EString.trim(value), parameters);
        }
        
        public function has(token:String):Boolean
        {
            return token in _values;
        }
        
        public function add(token:String, value:String = null, parameters:Object = null):HTTPHeader
        {
            _values[EString.trim(token)] = 
                new HTTPHeaderValue(EString.trim(token), EString.trim(value), parameters);
            return this;
        }
        
        public function remove(token:String):HTTPHeader
        {
            delete _values[token];
            return this;
        }
        
        public function clear():HTTPHeader
        {
            _values = { };
            return this;
        }
        
        public function extend(header:HTTPHeader):HTTPHeader
        {
            E.extend(_values, header._values, true);
            return this;
        }
        
        public function encode():ByteArray
        {
            var 
            bytes:ByteArray = new ByteArray;
            bytes.writeUTFBytes(toString());
            return bytes;
        }
        
        public function decode(bytes:ByteArray):HTTPHeader
        {
            parse(bytes.toString());
            return this;
        }
        
        public function parse(string:String):HTTPHeader
        {
            _values = { };
            
            var headerParts:Array = string.split(':');
            _name = EString.trim(headerParts.shift()).toLowerCase();
            if (UNBREAKABLE.indexOf(_name) == -1)
            {
                if (_name == SET_COOKIE)
                    headerParts = [ headerParts.join(':') ];
                else
                    headerParts = headerParts.join(':').split(',');
                
                for (var i:int = 0; i < headerParts.length; i++) 
                {
                    var valueParts:Array = headerParts[i].split(';');
                    var tokenParts:Array;
                    if (valueParts[0].indexOf('=') == valueParts[0].lastIndexOf('=') && _name != SET_COOKIE)
                        tokenParts = valueParts.shift().split('=');
                    else
                        tokenParts = [ valueParts.shift() ];
                    
                    var params:Object = { };
                    for (var j:int = 0; j < valueParts.length; j++) 
                    {
                        var tokenParams:Array = valueParts[j].split('=');
                        params[EString.trim(tokenParams.shift())] = tokenParams.length == 0 ? null : EString.trim(tokenParams.join('='));
                    }
                    
                    add(tokenParts.shift(), tokenParts.length == 0 ? null : tokenParts.join('='), params);
                }
            }
            else
            {
                var val:String = EString.trim(headerParts.join(':'));
                _values[val] = new HTTPHeaderValue(val);
            }
            
            return this;
        }
        
        public function clone():HTTPHeader
        {
            var result:HTTPHeader = new HTTPHeader(_name);
            result._values = E.clone(_values);
            return result;
        }
        
        public function name():String 
        { 
            return _name; 
        }
        
        public function value(token:String = null):*
        {
            var result:String = '';
            var value:HTTPHeaderValue;
            var name:String;
            
            if (token)
            {
                if (token in _values)
                {
                    value = _values[token];
                    result += value._token + (value._value ? '=' + value._value : '');
                    for (name in value._parameters) 
                        result += '; ' + name + (value._parameters[name] ? ('=' + String(value._parameters[name])) : '');
                }
            }
            else
            {
                for each (value in _values) 
                {
                    result += ', ' + value._token + (value._value ? '=' + value._value : '');
                    for (name in value._parameters) 
                        result += '; ' + name + (value._parameters[name] ? ('=' + String(value._parameters[name])) : '');
                }
                result = result.slice(2);
            }
            
            return result;
        }
        
        public function full():String
        {
            return name() + ': ' + value();
        }
        
        public function toString():String
        {
            return _name + ': ' + value();
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        
        public function get values():Object
        { 
            return E.clone(_values); 
        }
    }
}