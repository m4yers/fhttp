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
    import com.mayerscraft.compressing.GZIP;
    import com.mayerscraft.lang.EBytes;
    import com.mayerscraft.lang.EDate;
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.utilities.ErrorThrower;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    /**
     * 
     * @author Artyom Goncharov 17.12.2012 16:05
     */
    internal class HTTPCache 
    {
        private var MAGIC       :uint = (109 << 8) | 52;
        private var MAGIC_ERROR :String = 'This is not an HTTPCache file';
        
        private var _enabled :Boolean;
        private var _table   :Object;
        
        public function HTTPCache()
        {
            _enabled = true;
            _table = { };
        }
        
    //----------------------------------
    //  interface
    //----------------------------------
        public function load(bytes:ByteArray):void
        {
            if (GZIP.isGZIP(bytes))
            {
                var decompressed:Object = GZIP.decompress(bytes);
                
                if (decompressed.error)
                {
                    
                }
                else
                {
                    var bytes:ByteArray = decompressed.data;
                    if (bytes.readShort() == MAGIC)
                    {
                        while (bytes.bytesAvailable)
                        {
                            var response:HTTPResponse = new HTTPResponse();
                            var keyLen:int = bytes.readUnsignedInt();
                            var key:String = bytes.readMultiByte(keyLen, 'us-ascii');
                            var respLen:int =     bytes.readUnsignedInt();
                            response.deserialize(EBytes.readBody(bytes, null, respLen));
                            
                            _table[key] = response;
                        }
                    }
                    else
                    {
                        ErrorThrower.throwParameterIsWrong(toString(), 'bytes', MAGIC_ERROR);
                    }
                }
            }
        }
        
        public function dump():ByteArray
        {
            var 
            bytes:ByteArray = new ByteArray;
            bytes.writeShort(MAGIC);
            for (var name:String in _table) 
            {
                var response:HTTPResponse = _table[name];
                var record:ByteArray = response.serialize();
                
                bytes.writeUnsignedInt(name.length);
                bytes.writeMultiByte(name, 'us-ascii');
                
                bytes.writeUnsignedInt(record.length);
                bytes.writeBytes(record);
            }
            
            return GZIP.compress(bytes);
        }
        
        public function drop():void
        {
            _table = { };
        }
        
        public function remove(method:String, uri:String):void
        {
            
        }
        
        public function toString():String
        {
            return EString.toString(this, 'HTTPCache');
        }
        
    //----------------------------------
    //  internal
    //----------------------------------
        internal function take(request:HTTPRequest):HTTPResponse
        {
            sieve();
            
            var key:String = key(request);
            if (key in _table)
                return _table[key].clone();
            
            return null;
        }
        
        internal function store(response:HTTPResponse):void
        {
            if (!_enabled) return;
            
            sieve();
            
            var request:HTTPRequest = response._request;
            if (request._method == HTTPMethod.GET)
            {
                switch (response._code)
                {
                    case HTTPCode._200_OK:
                    case HTTPCode._201_CREATED:
                    case HTTPCode._202_ACCEPTED:
                    case HTTPCode._203_NON_AUTHORITATIVE:
                    case HTTPCode._204_NO_CONTENT:
                    case HTTPCode._205_RESET_CONTENT:
                    //case HTTPCode._206_PARTIAL_CONTENT:    // MERGE CACHE
                    case HTTPCode._300_MULTIPLE_CHOICES:
                    case HTTPCode._301_MOVED_PERMANENTLY:
                    case HTTPCode._302_FOUND:                // ONLY IF INDICATED
                    {
                        age(response);
                        var key:String = key(request);
                        _table[key] = response.clone();
                        _table[key]._encoded = response._encoded;
                    }
                }
            }
        }
        
    //----------------------------------
    //  private
    //----------------------------------
        private function sieve():void
        {
            var now:Date = new Date();
            var time:uint = now.time / 1000.0;
            
            for (var key:String in _table) 
            {
                var response        :HTTPResponse = _table[key];
                var headers            :Object = response._headers;
                var age                :HTTPHeader = headers[HTTPHeader.AGE] || new HTTPHeader(HTTPHeader.AGE);
                var warning            :HTTPHeader = headers[HTTPHeader.WARNING];
                var expires            :HTTPHeader = headers[HTTPHeader.EXPIRES];
                var cache_control    :HTTPHeader = headers[HTTPHeader.CACHE_CONTROL];
                
                age.clear().add(uint(time - response._time.time / 1000.0).toString());
                    
                
                if (expires)
                {
                    var edate:Date = EDate.toDate(expires.value());
                    if (!edate || time >= edate.time / 1000)
                    {
                        warning = warning || new HTTPHeader(HTTPHeader.WARNING);
                        warning.add(HTTPWarning.STALE.toString());
                    }
                }
                
                if (cache_control)
                {
                    if (cache_control.has('no-cache') || cache_control.has('no-store'))
                    {
                        delete _table[key];
                    } 
                    else if (cache_control.has('max-age'))
                    {
                        if (int(age.value()) >= int(cache_control.value('max-age')))
                        {
                            warning = warning || new HTTPHeader(HTTPHeader.WARNING);
                            warning.add(HTTPWarning.STALE.toString());
                        }
                        else if (warning)
                        {
                            warning.remove(HTTPWarning.STALE.toString());
                        }
                    }
                }
                
                if (warning)
                    headers[HTTPHeader.WARNING] = warning;
            }
        }
    
        private function age(response:HTTPResponse):void
        {
            response._time = new Date();
            
            var request:HTTPRequest = response._request;
            var headers:Object = response._headers;
            
            /*
             * It does not seem right, but it's the standart.
             * 
             * Age calculations:
             * http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.2.3
             * 
             * age_value
             *      is the value of Age: header received by the cache with
             *              this response.
             * date_value
             *      is the value of the origin server's Date: header
             * request_time
             *      is the (local) time when the cache made the request
             *              that resulted in this cached response
             * response_time
             *      is the (local) time when the cache received the
             *              response
             * now
             *      is the current (local) time
             * 
             * apparent_age = max(0, response_time - date_value);
             * corrected_received_age = max(apparent_age, age_value);
             * response_delay = response_time - request_time;
             * corrected_initial_age = corrected_received_age + response_delay;
             * resident_time = now - response_time;
             * current_age   = corrected_initial_age + resident_time;
             * */
            var offset                  :Number = request._time.getTimezoneOffset() * 60;
            var age_value               :Number = headers[HTTPHeader.AGE] || 0.0;
            var date_value              :Number = HTTPHeader.DATE in headers ? EDate.toDate(headers[HTTPHeader.DATE].value()).getTime() / 1000 : 0.0;
            var now                     :Number = new Date().getTime() / 1000 + offset;
            var request_time            :Number = request._time.getTime() / 1000 + offset;
            var response_time           :Number = response._time.getTime() / 1000 + offset;
            
            var apparent_age            :Number = Math.max(0, now - date_value);
            var corrected_received_age  :Number = Math.max(apparent_age, age_value);
            var response_delay          :Number = response_time - request_time;
            var corrected_initial_age   :Number = corrected_received_age + response_delay;
            var resident_time           :Number = now - response_time;
            var current_age             :Number = Math.min(uint.MAX_VALUE, uint(corrected_initial_age + resident_time));
            
            headers[HTTPHeader.AGE] = new HTTPHeader(HTTPHeader.AGE, uint(current_age).toString());
        }
        
        private function key(request:HTTPRequest):String
        {
            return request._method + '::' + EString.trim(request._uri.toString(), '/');
        }
        
        public function get enabled():Boolean 
        { 
            return _enabled; 
        }
        
        public function set enabled(value:Boolean):void 
        { 
            _enabled = value; 
        }
    }
}