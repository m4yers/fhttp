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
    import com.mayerscraft.http.events.HTTPClientEvent;
    import com.mayerscraft.http.events.HTTPSocketEvent;
    import com.mayerscraft.lang.EBytes;
    import com.mayerscraft.lang.EDate;
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.log.Logger;
    import com.mayerscraft.utilities.ErrorThrower;
    import flash.events.EventDispatcher;
    
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 12:04
     */
    public class HTTPClient extends EventDispatcher
    {
        private static const ERROR_SETTINGS:String 
            = 'The HTTP client have started, you cannot use settings now';
        private static const WARNING_SUPERFLUOUS:String 
            = 'The HTTP client received superfluous data from the server {0}:{1}.';
        
        private var _sockets    :Object;
        private var _logger     :Logger;
        private var _settings   :HTTPSettings;
        private var _cache      :HTTPCache;
        private var _cookies    :HTTPCookies;
        
        public function HTTPClient() 
        {
            _logger = Logger.get('http');
            _logger.enabled = false;
            _sockets = { };
            _settings = new HTTPSettings;
            _settings.socket.encoding = HTTPEncoding.TYPE_GZIP;
            _cache = new HTTPCache;
        }
        
    //----------------------------------
    //  interface
    //----------------------------------
        public function send(request:HTTPRequest):HTTPResponse
        {
            action(toString() + '.send ' + request.toString());
            
            requestHandler(request);
            
            var response:HTTPResponse = _cache.take(request);
            
            if (response)
            {
                action(toString() + '.send, cache ' + response.toString());
                response = cacheHandler(request, response);
            }
            else
            {
                action(toString() + '.send, no cache, append to socket');
                response = socket(request).append(request);
                response._request = request;
            }
            
            _settings.client.started = true;
            
            return response;
        }
        
        public function request(method:String, uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(method, uri, headers, data));
        }
        
        public function options(uri:String, headers:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.OPTIONS, uri, headers, null));
        }
        
        public function head(uri:String, headers:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.HEAD, uri, headers, null));
        }
        
        public function get(uri:String, headers:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.GET, uri, headers, null));
        }
        
        public function post(uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.POST, uri, headers, data));
        }
        
        /*public function put(uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.PUT, uri, headers, data));
        }
        
        public function del(uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.DELETE, uri, headers, data));
        }
        
        public function trace(uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.TRACE, uri, headers, data));
        }
        
        public function connect(uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.CONNECT, uri, headers, data));
        }
        
        public function patch(uri:String, headers:Object = null, data:Object = null):HTTPResponse
        {
            return send(new HTTPRequest(HTTPMethod.PATCH, uri, headers, data));
        }*/
        
        override public function toString():String 
        {
            return EString.toString(this, 'HTTPClient');
        }
        
    //----------------------------------
    //  implementation
    //----------------------------------
        private function socket(request:HTTPRequest):HTTPSocket
        {
            var uri:URI = request._proxy ? request._proxy : request._uri;
            var key:String = (uri.scheme == 'https' ? 'https' : 'http') + '://' + uri.authority;
            var vector:Vector.<HTTPSocket> = _sockets[key];
            var socket:HTTPSocket;
            
            if (vector)
            {
                /**
                 * Choosing less busiest socket or create one.
                 */
                var mv:int = int.MAX_VALUE;
                var mi:int = int.MAX_VALUE;
                for (var i:int = 0; i < vector.length; i++) 
                {
                    if (mv > vector[i].pendings.length + vector[i].queued.length)
                    {
                        mv = vector[i].pendings.length + vector[i].queued.length;
                        mi = i;
                    }
                }
                
                if (_settings.connection.density > mv 
                 || _settings.connection.parallels <= vector.length)
                    socket = vector[mi];
            }
            else
            {
                _sockets[key] = new Vector.<HTTPSocket>;
            }
            
            if (!socket)
            {
                socket = new HTTPSocket(
                    _settings.branch(), 
                    uri.authority, 
                    uri.port && uri.port != '' ? int(uri.port) : (uri.scheme == 'https' ? 443 : 80), 
                    uri.scheme == 'https',
                    _logger);
                socket.addEventListener(HTTPSocketEvent.ERROR,       socketEventHandler, false, 0, false);
                socket.addEventListener(HTTPSocketEvent.DATA,        socketEventHandler, false, 0, false);
                socket.addEventListener(HTTPSocketEvent.COMPLETE,    socketEventHandler, false, 0, false);
                socket.addEventListener(HTTPSocketEvent.SUPERFLUOUS, socketEventHandler, false, 0, false);
                socket.addEventListener(HTTPSocketEvent.CLOSE,       socketEventHandler, false, 0, false);
                
                _sockets[key].push(socket);
            }
            
            socket.open();
            
            return socket;
        }
        
        private function requestHandler(request:HTTPRequest):HTTPRequest
        {
            action(toString() + '.requestHandler ' + request.toString());
            
            request._time = new Date();
            
            var 
            headers:Object = request._headers;
            headers[HTTPHeader.HOST] = new HTTPHeader(HTTPHeader.HOST);
            headers[HTTPHeader.USER_AGENT] = new HTTPHeader(HTTPHeader.USER_AGENT, 
                _settings.client.name + '/' + _settings.client.verstion);
            
            if (request._proxy)
            {
                headers[HTTPHeader.HOST].add(request._proxy.authority + (request._proxy.port == '' ? '' : ':' + request._proxy.port));
                request._request = request._uri.toString();
            }
            else
            {
                headers[HTTPHeader.HOST].add(request._uri.authority + (request._uri.port == '' ? '' : ':' + request._uri.port));
                request._request  = request._uri.path == '' ? '/' : request._uri.path;
                request._request += request._uri.queryRaw == '' ? '' : '?' + request._uri.queryRaw;
            }
            
            return request;
        }
        
        private function responseHandler(request:HTTPRequest, response:HTTPResponse, socket:HTTPSocket = null):HTTPResponse
        {
            action(toString() + '.responseHandler ' + request.toString() + response.toString());
            debug(response.toString(true));
            
            var headers:Object = response._headers;
            
            if (socket
             && (HTTPHeader.CONNECTION in headers 
                && headers[HTTPHeader.CONNECTION].value() == 'close')
             || (HTTPHeader.PROXY_CONNECTION in headers 
                && headers[HTTPHeader.PROXY_CONNECTION].value() == 'close')
             || _settings.connection.isTerminable)
             {
                close(socket);
             }
             
            
            switch (response._code)
            {
                case HTTPCode._300_MULTIPLE_CHOICES:
                case HTTPCode._301_MOVED_PERMANENTLY:
                case HTTPCode._302_FOUND:
                case HTTPCode._307_TEMPORARY_REDIRECT:
                {
                    //TODO: check loops
                    action(toString() + '.responseHandler, redirect');
                    if (_settings.redirect.isAll
                    || (_settings.redirect.isSafe 
                        && HTTPMethod.SAFES.indexOf(request._method) != -1)
                    || (_settings.redirect.isIdempotent 
                        && HTTPMethod.IDEMPOTENTS.indexOf(request._method) != -1))
                    {
                        if (!redirect(request, response))
                            notify(request, response, HTTPClientEvent.COMPLETE);
                    }
                    else
                    {
                        notify(request, response, HTTPClientEvent.REDIRECT,
                        {
                            redirect: function():void { redirect(request, response) }
                        });
                    }
                    
                    break;
                }
                case HTTPCode._303_SEE_OTHER:                                //TODO: TEST THIS CAREFULLY
                {
                    action(toString() + '.responseHandler, see other');
                    if (!redirect(new HTTPRequest(HTTPMethod.GET, null), response))
                        notify(request, response, HTTPClientEvent.COMPLETE);
                }
                case HTTPCode._304_NOT_MODIFIED:
                {
                    action(toString() + '.responseHandler, not modified');
                    response.identify(_cache.take(request))
                    responseHandler(request, response);
                    break;
                }
                case HTTPCode._305_USE_PROXY:                                //TODO: get back here when proxy is tested
                {
                    action(toString() + '.responseHandler, use proxy');
                    break;
                }
                default:
                {
                    notify(request, response, HTTPClientEvent.COMPLETE);
                    break;
                }
            }
             
             return response;
        }
        
        private function cacheHandler(request:HTTPRequest, response:HTTPResponse):HTTPResponse
        {
            action(toString() + '.cacheHandler ' + request.toString() + response.toString());
            
            var headers:Object = response._headers;
            
            var last_modified:HTTPHeader = headers[HTTPHeader.LAST_MODIFIED];
            if (last_modified)
            {
                action(toString() + '.cacheHandler, last modified, append to socket');
                request._headers[HTTPHeader.IF_MODIFIED_SINCE] 
                        = new HTTPHeader(HTTPHeader.IF_MODIFIED_SINCE, last_modified.value());
                    
                response = socket(request).append(request);
                response._request = request;
                
                return response;
            }
            
            var etag:HTTPHeader = headers[HTTPHeader.ETAG];
            if (etag)
            {
                action(toString() + '.cacheHandler, etag, append to socket');
                request._headers[HTTPHeader.IF_NONE_MATCH] 
                        = new HTTPHeader(HTTPHeader.IF_NONE_MATCH, etag.value());
                    
                response = socket(request).append(request);
                response._request = request;
                
                return response;
            }
            
            var warning:HTTPHeader = headers[HTTPHeader.WARNING];
            if (warning)
            {
                if (HTTPWarning.STALE.toString() in warning._values)
                {
                    action(toString() + '.cacheHandler, stale, append to socket');
                    request._headers[HTTPHeader.IF_MODIFIED_SINCE] 
                        = new HTTPHeader(HTTPHeader.IF_MODIFIED_SINCE, EDate.toRFC1123(response._time));
                    
                    response = socket(request).append(request);
                    response._request = request;
                    
                    return response;
                }
            }
            
            switch (response._code)
            {
                case HTTPCode._300_MULTIPLE_CHOICES:
                case HTTPCode._302_FOUND:
                {
                    action(toString() + '.cacheHandler, socket');
                    response = socket(request).append(request);
                    response._request = request;
                    break;
                }
                case HTTPCode._301_MOVED_PERMANENTLY:
                {
                    action(toString() + '.cacheHandler, redirect');
                    if (!redirect(request, response))
                        notify(request, response, HTTPClientEvent.COMPLETE);
                    break;
                }
                default:
                {
                    action(toString() + '.cacheHandler, using cache');
                    responseHandler(request, response);
                    break;
                }
            }
            
            return response;
        }
        
        private function redirect(request:HTTPRequest, response:HTTPResponse):Boolean
        {
            action(toString() + '.redirect '  + request.toString() + response.toString());
            var location:HTTPHeader = response._headers[HTTPHeader.LOCATION];
            if (location)
            {
                var 
                clone:HTTPRequest = request.clone();
                clone._uri = new URI(location.value());
                var response:HTTPResponse = _cache.take(requestHandler(clone));
                if (response)
                {
                    action(toString() + '.redirect, cache');
                    response = cacheHandler(clone, response);
                }
                else
                {
                    action(toString() + '.redirect, socket');
                    socket(clone).append(clone)._previous = response;
                }
                return true;
            }
            
            return false;
        }
        
        private function close(socket:HTTPSocket):void
        {
            action(toString() + '.close ' + socket.toString());
            if (socket.queued.length == 0 && socket.pendings.length == 0)
            {
                socket.close();
            }
            else
            {
                action(toString() + '.close, reopen');
                
                var pendings:Vector.<HTTPRequest> = socket.pendings;
                if (pendings.length > 1)
                {
                    action(toString() + '.close, changing pipeline settings');
                    socket.settings.pipeline.none();
                }
                    
                for (var i:int = 0; i < pendings.length; i++) 
                {
                    var request:HTTPRequest = pendings[i];
                    if (request._iteration >= 2 || _settings.retry.isNone
                     || (_settings.retry.isSafe
                        && HTTPMethod.SAFES.indexOf(request._method) == -1))
                     {
                        var flag:Boolean;
                        notify(request, request._response, HTTPClientEvent.RETRY, 
                        {
                            iteration: request._iteration,
                                retry: function():void { flag = true }
                        }) 
                        
                        if (flag)
                        {
                            flag = false;
                            pendings.splice(i, 1);
                            i--;
                        }
                     }
                     else
                     {
                        pendings.splice(i, 1);
                        i--;
                     }
                }
                
                socket.close();
                
                while (pendings.length != 0)
                    socket.drop(pendings.pop());
                
                if (socket.queued.length != 0)
                    socket.open();
            }
        }
        
        private function notify(request:HTTPRequest, response:HTTPResponse, event:String, data:Object = null):void
        {
            action(toString() + '.notify, ' + event + ' ' + request.toString() + response.toString());
            
            data = data || { };
            
            if (request && request.hasEventListener(event))
            {
                data['response'] = response;
                request.dispatchEvent(new HTTPClientEvent(event, data));
            }
            else if (response && response.hasEventListener(event))
            {
                data['request'] = request;
                response.dispatchEvent(new HTTPClientEvent(event, data));
            }
            else if (hasEventListener(HTTPClientEvent.COMPLETE))
            {
                data['request'] = request;
                data['response'] = response;
                dispatchEvent(new HTTPClientEvent(event, data));
            }
        }
        
    //----------------------------------
    //  DELEGATE Logger
    //----------------------------------
        private function action(message:String):void 
        {
            _logger.action(message);
        }
        
        private function debug(message:String):void 
        {
            _logger.debug(message);
        }
        
        private function error(message:String):void 
        {
            _logger.error(message);
        }
        
        private function message(message:String):void 
        {
            _logger.message(message);
        }
        
        private function warning(message:String):void 
        {
            _logger.warning(message);
        }
        
    //--------------------------------------------------------------------------
    //
    //  Handlers
    //
    //--------------------------------------------------------------------------
        
        private function socketEventHandler(event:HTTPSocketEvent):void 
        {
            var socket:HTTPSocket = event.data.socket;
            var request:HTTPRequest = event.data.request;
            var response:HTTPResponse = event.data.response;
            
            debug(event.toString());
            
            if (request)
                action(toString() + '.socketEventHandler, ' + request.toString() + response.toString());
            else
                action(toString() + '.socketEventHandler ');
            
            switch (event.type)
            {
                case HTTPSocketEvent.COMPLETE:
                {
                    action(toString() + '.socketEventHandler, complete');
                     _cache.store(response);
                    responseHandler(request, response, socket);
                    
                    break;
                }
                
                case HTTPSocketEvent.DATA:
                {
                    action(toString() + '.socketEventHandler, data');
                    notify(request, response, HTTPClientEvent.DATA);
                    break;
                }
                
                case HTTPSocketEvent.SUPERFLUOUS:
                {
                    action(toString() + 'socketEventHandler, superfulous ' +  EBytes.toChars(event.data.buffer));
                    notify(request, response, HTTPClientEvent.WARNING, 
                    {  
                        text: EString.format(WARNING_SUPERFLUOUS, socket.host, socket.port),
                        data: event.data.buffer
                    });
                    break;
                }
                
                case HTTPSocketEvent.ERROR:
                {
                    error(toString() + '.socketEventHandler, ' + event.data.errorID + ', ' + event.data.text);
                    close(socket);
                    break;
                }
                case HTTPSocketEvent.CLOSE:
                {
                    action(toString() + '.socketEventHandler, close');
                    close(socket);
                    break;
                }
            }
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        public function get settings():HTTPSettings 
        { 
             _settings.client.started
                && ErrorThrower.throwIllegalOperation(toString(), ERROR_SETTINGS);
            return _settings; 
        }
        
        public function get logger():Logger 
        { 
            return _logger; 
        }
        
        public function get cache():HTTPCache 
        { 
            return _cache; 
        }
        
        public function get cookies():HTTPCookies 
        { 
            return _cookies; 
        }
    }
}