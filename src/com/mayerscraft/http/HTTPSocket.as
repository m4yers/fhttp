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
    import com.mayerscraft.http.events.HTTPSocketEvent;
    import com.mayerscraft.lang.E;
    import com.mayerscraft.lang.EBytes;
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.log.Logger;
    import com.mayerscraft.mime.IMIMEObject;
    import com.mayerscraft.utilities.timers.Timers;
    import com.mayerscraft.utilities.timers.TimersEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.SecureSocket;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 13:10
     */
    internal class HTTPSocket extends EventDispatcher
    {
        public static const NONE                :int = 0;   // created but not connected.
        public static const IDLE                :int = 1;   // created and connected.
        public static const PENDING_CONTINUE    :int = 2;   // waiting for 100 code to send data.
        public static const PENDING_SUCCESS     :int = 3;   // waiting for 2** response.
        public static const PENDING_NEXT        :int = 4;   // waiting for next message part.
        
        public static const REGEXP_STATUS_LINE:RegExp = /^HTTP\/(?P<version>1\.[01]) (?P<status>\d{3})(?:[ ]+(?P<reason>.+))?$/;
        
        public static const HTTP    :String = 'HTTP';
        public static const VERSION :String = 'HTTP/1.1';
        public static const CHARSET :String = 'us-ascii';
        public static const DIGIT   :Vector.<int> = Vector.<int>([48, 49, 50, 51, 52, 53, 54, 55, 56, 57]);
        public static const CTL     :Vector.<int> = Vector.<int>([]);
        public static const CL      :int = 58;    // color
        public static const SL      :int = 47;    // slash
        public static const BS      :int = 92;    // backslash
        public static const QS      :int = 63;    // question mark
        public static const SQ      :int = 39;    // single-quote
        public static const DQ      :int = 34;    // double-quote
        public static const CR      :int = 13;    // caret return
        public static const LF      :int = 10;    // linefeed
        public static const SP      :int = 32;    // space
        public static const HT      :int = 9;    // horizontal-tab
        
        private static const TIMER_TIMEOUT_NAME     :String = 'timer_timeout';
        private static const TIMER_CONTINUE_NAME    :String = 'timer_continue';
        private static const TIMER_CONTINUE_DELAY   :Number = 1000;
        
        private var _logger     :Logger;
        private var _settings   :HTTPSettings;
        private var _state      :int = NONE;
        private var _host       :String;
        private var _port       :int;
        private var _secure     :Boolean;
        private var _socket     :Socket;
        private var _timers     :Timers = new Timers();
        private var _queue      :Vector.<HTTPRequest> = new Vector.<HTTPRequest>;
        private var _pending    :Vector.<HTTPResponse> = new Vector.<HTTPResponse>;
        private var _current    :HTTPResponse = new HTTPResponse();
        
        public function HTTPSocket(settings:HTTPSettings, host:String, port:int, secure:Boolean, logger:Logger) 
        {
            _settings = settings;
            _host = host;
            _port = port;
            _secure = secure;
            _logger = logger;
            _timers.addEventListener(TimersEvent.TIMER, timersEventHandler, false, 0, false);
        }
        
        public function open():HTTPSocket
        {
            action(toString() + '.open ' + _host + ':' + _port.toString());
            
            if (!_socket)
            {
                _socket = _secure ? new SecureSocket() : new Socket();
                _socket.addEventListener(IOErrorEvent.IO_ERROR,             socketEventHandler, false, 0, false);
                _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketEventHandler, false, 0, false);
                _socket.addEventListener(ProgressEvent.SOCKET_DATA,         socketEventHandler, false, 0, false);
                _socket.addEventListener(Event.CONNECT,                     socketEventHandler, false, 0, false);
                _socket.addEventListener(Event.CLOSE,                       socketEventHandler, false, 0, false);
                _socket.timeout = _settings.connection.timeout;
                _socket.connect(host, port);
            }
            
            return this;
        }
        
        public function close():HTTPSocket
        {
            action(toString() + '.close ' + _host + ':' + _port.toString());
            
            if (_socket)
            {
                _socket.close();
                _socket.removeEventListener(IOErrorEvent.IO_ERROR,             socketEventHandler, false);
                _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, socketEventHandler, false);
                _socket.removeEventListener(ProgressEvent.SOCKET_DATA,         socketEventHandler, false);
                _socket.removeEventListener(Event.CONNECT,                     socketEventHandler, false);
                _socket.removeEventListener(Event.CLOSE,                       socketEventHandler, false);
                _socket = null;
                
                while (_pending.length != 0)
                {
                    var 
                    response:HTTPResponse = _pending.pop();
                    response.identify();
                    _queue.unshift(response._request);
                }
                
                _current.identify();
                
                _timers.stop();
                _state = NONE;
                _host = _host
            }
            
            return this;
        }
        
        public function prepend(request:HTTPRequest):HTTPResponse
        {
            action(toString() + '.prepend ' + request.toString());
            
            var 
            response:HTTPResponse = new HTTPResponse;;
            response._request = request;
            
            request._frozen = true;
            request._response = response;
            _queue.unshift(request);
            
            queue();
            
            return response;
        }
        
        public function append(request:HTTPRequest):HTTPResponse
        {
            action(toString() + '.append ' + request.toString());
            
            var 
            response:HTTPResponse = new HTTPResponse;
            response._request = request;
            
            request._frozen = true;
            request._response = response;
            _queue.push(request);
            
            queue();
            
            return response;
        }
        
        public function drop(request:HTTPRequest):void
        {
            action(toString() + '.drop ' + request.toString());
            
            var index:int = _queue.indexOf(request);
            if (index != -1)
                _queue.splice(index, 1);
        }
        
        override public function toString():String 
        {
            return EString.toString(this, 'HTTPSocket', 'host', 'port');
        }
        
    //--------------------------------------------------------------------------
    //
    //  Request
    //
    //--------------------------------------------------------------------------
        private function queue():void
        {
            //action('HTTPSocket.queue');
            
            if (!connected) 
                return;
            
            if (_queue.length == 0) 
                return;
                
            if (_state != IDLE
             && _state != PENDING_SUCCESS)
                return;
             
            if (_state == PENDING_SUCCESS
            && (_settings.connection.isTerminable 
                ||  _settings.pipeline.isNone 
                || (_settings.pipeline.isSafe 
                    && HTTPMethod.IDEMPOTENTS.indexOf(_queue[0]._method) == -1)))
                return;
                
            var request:HTTPRequest = _queue.shift();
            var headers:Object = request._headers;
            var message:ByteArray;
            
            action(toString() + '.queue ' + request.toString());
            
            request._iteration++;
            
            headers[HTTPHeader.ACCEPT]          = new HTTPHeader(HTTPHeader.ACCEPT, '*/*');
            headers[HTTPHeader.ACCEPT_ENCODING] = new HTTPHeader(HTTPHeader.ACCEPT_ENCODING, 'gzip');
            headers[HTTPHeader.CONNECTION]      = new HTTPHeader(HTTPHeader.CONNECTION, 
                _settings.connection.isPersistent ? 'keep-alive' : 'close');
            //headers[HTTPHeader.ACCEPT_ENCODING] = new HTTPHeader(HTTPHeader.ACCEPT_ENCODING, 'gzip');
            //headers[HTTPHeader.TE]                 = 'gzip';
            
            switch (request._method)
            {
                case HTTPMethod.OPTIONS:
                {
                    message = writeRequest(request, new ByteArray);
                    _state = PENDING_SUCCESS;
                    break;
                }
                case HTTPMethod.GET:     
                { 
                    message = writeRequest(request, new ByteArray);
                    _state = PENDING_SUCCESS;
                    break; 
                }
                case HTTPMethod.HEAD:
                {
                    message = writeRequest(request, new ByteArray);
                    _state = PENDING_SUCCESS;
                    break;
                }
                case HTTPMethod.POST:     
                { 
                    if (request._data is IMIMEObject)
                        HTTPContent.encode(request);
                    else
                        request._encoded = EBytes.toBytes(request._data);
                    
                    delete headers[HTTPHeader.TRANSFER_ENCODING];
                    delete headers[HTTPHeader.CONTENT_LENGTH];
                    
                    if (request._encoded.length > 0)
                    {
                        HTTPEncoding.encode(request, _settings.socket.encoding);
                        HTTPTransport.to(request);
                        
                        if (_settings.socket.expectContinue)
                        {
                            headers[HTTPHeader.EXPECT] 
                                = new HTTPHeader(HTTPHeader.EXPECT, '100-continue');
                            message = writeRequest(request, new ByteArray);
                            _timers.start(TIMER_CONTINUE_NAME, TIMER_CONTINUE_DELAY);
                            _state = PENDING_CONTINUE;
                        }
                        else
                        {
                            message = writeRequest(request, new ByteArray);
                            message.writeBytes(request._encoded, 0, 0);
                            _state = PENDING_SUCCESS;
                        }
                    }
                    else
                    {
                        headers[HTTPHeader.CONTENT_LENGTH] 
                            = new HTTPHeader(HTTPHeader.CONTENT_LENGTH, '0');
                        message = writeRequest(request, new ByteArray);
                        _state = PENDING_SUCCESS;
                    }
                    
                    break;
                }
                default:    
                { 
                    throw request._method + ' has not been implemented yet.'    
                }
            }
                
            debug(request.toString(true));
            
            if (message)
            {
                _pending.push(request._response);
                _timers.start(TIMER_TIMEOUT_NAME, _settings.connection.timeout, 0, true);
                push(message);
            }
        }
        
        private function push(message:ByteArray):void
        {
            _socket.writeBytes(message, 0, 0);
            _socket.flush();
            queue();
        }
        
        private function writeRequest(request:HTTPRequest, bytes:ByteArray):ByteArray
        {
            bytes == bytes || new ByteArray;
            bytes.clear();
            bytes.writeMultiByte(request._method, CHARSET);     // method
            bytes.writeByte(SP);
            bytes.writeMultiByte(request._request, CHARSET);    // request
            bytes.writeByte(SP);
            bytes.writeMultiByte(VERSION, CHARSET);             // version
            bytes.writeByte(CR);                                // status end
            bytes.writeByte(LF);    
            
            for (var name:String in request._headers)           // headers
            {
                bytes.writeMultiByte(request._headers[name].name(), CHARSET);
                bytes.writeByte(CL);
                bytes.writeByte(SP);
                bytes.writeMultiByte(request._headers[name].value(), CHARSET);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
            }
            
            bytes.writeByte(CR);                                // headers end
            bytes.writeByte(LF);
            
            return bytes;
        }
        
    //--------------------------------------------------------------------------
    //
    //  Response
    //
    //--------------------------------------------------------------------------
        private function pull(buffer:ByteArray, response:HTTPResponse):void
        {
            action(toString() + '.pull ' + response.toString());
            
            var state       :int        = response._state == HTTPResponse.STATE_NONE ? HTTPResponse.STATE_STATUS : response._state;
            var message     :ByteArray  = response._message;
            var headers     :Object     = response._headers;
            var encoded     :ByteArray;
            var prevHeader  :String;
            
            buffer.readBytes(message, message.length, buffer.bytesAvailable)
                
            var line:ByteArray;
            while (message.bytesAvailable > 0)
            {
                if (state == HTTPResponse.STATE_STATUS)
                {
                    line = EBytes.readLine(message);
                    if (line.length == 0)
                    {
                        continue;
                    }
                    else
                    {
                        //etrace('status: ' + 'HTTP/1.1 123 Some long explanation'.match(REGEXP_STATUS_LINE));
                        var status:Array = line.toString().split(String.fromCharCode(SP));
                        if (status.length >= 3)
                        {
                            response._version   = Number(status.shift().split('/')[1]);
                            response._code      = int(status.shift());
                            response._phrase    = status.join(String.fromCharCode(SP));
                            state = HTTPResponse.STATE_HEADERS;
                            
                            if (EBytes.isNext(message, CR, LF))                                    // Message has only status field
                            {
                                message.position += 2;
                                state = HTTPResponse.STATE_COMPLETE;
                            }
                            else
                            {
                                state = HTTPResponse.STATE_HEADERS;
                            }
                            
                            action(toString() + '.pull status ' + line.toString());
                        }
                        else
                        {
                            /**
                             * puller have read full status-line, but cannot
                             * resolve it, unknown format
                             */
                            if (message.length != line.length)
                            {
                                //TODO: make here some notification
                            }
                        }
                    }
                }
                else if (state == HTTPResponse.STATE_HEADERS)
                {
                    line = EBytes.readLine(message);
                    // end of the headers part of the message
                    if (line.length == 0)
                    {
                        action(toString() + '.pull headers complete ');
                        state = HTTPResponse.STATE_DATA
                    }
                    // header continues on the second line
                    else if ((EBytes.isNext(line, SP) || EBytes.isNext(line, HT)) && prevHeader)
                    {
                            line.position++;
                            headers[prevHeader] = headers[prevHeader].parse(headers[prevHeader].full() + line.toString());
                    }
                    else
                    {
                        var header:HTTPHeader = new HTTPHeader().decode(line);
                        action(toString() + '.pull header ' + header);
                        if (header._name in headers)
                            headers[header._name].extend(header);
                        else
                            headers[header._name] = header;
                    }
                }
                else if (state == HTTPResponse.STATE_DATA)
                {
                    action(toString() + '.pull data ');
                    
                    encoded = encoded || response._encoded || new ByteArray;
                    
                    if (HTTPHeader.CONTENT_LENGTH in headers 
                        && headers[HTTPHeader.CONTENT_LENGTH].value() != '0')
                    {
                        if (encoded.length == 0)
                            encoded.length = headers[HTTPHeader.CONTENT_LENGTH].value();
                        
                        EBytes.readBody(message, encoded, encoded.bytesAvailable);
                        
                        if (encoded.bytesAvailable == 0)
                            state = HTTPResponse.STATE_COMPLETE;
                    }
                    else if (HTTPHeader.TRANSFER_ENCODING in headers 
                        && headers[HTTPHeader.TRANSFER_ENCODING].value() == 'chunked')
                    {
                        if (EBytes.readChunk(message, encoded))    // if last chunk
                        {
                            message.position += 5;
                            headers[HTTPHeader.CONTENT_LENGTH] 
                                = new HTTPHeader(HTTPHeader.CONTENT_LENGTH, encoded.length.toString());
                            delete headers[HTTPHeader.TRANSFER_ENCODING];
                            state = HTTPResponse.STATE_COMPLETE;
                        }
                    }
                    else if ((HTTPHeader.CONNECTION in headers 
                        && headers[HTTPHeader.CONNECTION].value() == 'close')
                        || (HTTPHeader.PROXY_CONNECTION in headers 
                            && headers[HTTPHeader.PROXY_CONNECTION].value() == 'close'))
                    {
                        EBytes.readBody(message, encoded, message.bytesAvailable);
                    }
                    else
                    {
                        action(toString() + '.pull data complete ');
                        state = HTTPResponse.STATE_COMPLETE;
                    }
                }
                
                if (state == HTTPResponse.STATE_COMPLETE)
                {
                    buffer.position = buffer.length - message.bytesAvailable;
                    message.length -= message.bytesAvailable;
                    break;
                }
            }
            
            response._state = state;
            response._message = message;
            response._headers = headers;
            response._encoded = encoded;
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
        private function socketEventHandler(event:Event):void 
        {
            debug(event.toString());
            action(toString() + '.socketEventHandler');
            
            switch (event.type)
            {
                case IOErrorEvent.IO_ERROR:
                case SecurityErrorEvent.SECURITY_ERROR:
                {
                    dispatchEvent(new HTTPSocketEvent(HTTPSocketEvent.ERROR, 
                    { 
                         socket: this,
                        errorID: IOErrorEvent(event).errorID,
                           text: IOErrorEvent(event).text
                    }));
                    break;
                }
                
                case ProgressEvent.SOCKET_DATA:
                {
                    var buffer:ByteArray = new ByteArray;
                    _socket.readBytes(buffer, 0, _socket.bytesAvailable);
                    
                    /*etrace('---------------------buffer---------------------');
                    etrace(buffer.toString());
                    etrace('------------------------------------------------');*/
                    
                    while (connected && buffer.bytesAvailable > 0)
                    {
                        var response:HTTPResponse = _pending.length == 0 ? null : _pending[0];
                        if (response)
                        {
                            var request:HTTPRequest = response._request;
                            var headers:Object = response._headers;
                            
                            _current._request = request;
                            
                            pull(buffer, _current);
                            
                            if (_current._state == HTTPResponse.STATE_COMPLETE)
                            {
                                _timers.stop(TIMER_TIMEOUT_NAME);
                                
                                if (_current._encoded)
                                {
                                    HTTPEncoding.decode(_current);
                                    HTTPContent.decode(_current);
                                }
                                
                                switch (_current._code)
                                {
                                    case HTTPCode._100_CONTINUE:
                                    {
                                        if (_state == PENDING_CONTINUE)
                                        {
                                            _timers.stop(TIMER_CONTINUE_NAME);
                                            _state = PENDING_SUCCESS;
                                            push(_pending[0]._request._encoded);
                                        }
                                        
                                        break;
                                    }
                                    case HTTPCode._417_EXPECTATION_FAILED:
                                    {
                                        /**
                                         * 
                                         * 
                                         */
                                        if (_state == PENDING_CONTINUE)
                                        {
                                            
                                        }
                                        break;
                                    }
                                    case 501:
                                    {
                                        // Server cannot accept some Content_* Header, retry with different
                                        // params, if possible or notify client.
                                        break;
                                    }
                                    default:
                                    {
                                        if (_state == PENDING_CONTINUE)
                                        {
                                            _timers.stop(TIMER_CONTINUE_NAME);
                                            _settings.socket.expectContinue = false;
                                            _queue.unshift(_pending.shift()._request);
                                            queue();
                                            break;
                                        }
                                        
                                        /**
                                         * Copy result to the actual response object.
                                         */
                                        response.identify(_current);
                                        
                                        _pending.shift();
                                        if (_pending.length == 0)
                                            _state = IDLE;
                                        
                                        dispatchEvent(new HTTPSocketEvent(HTTPSocketEvent.COMPLETE, 
                                        {
                                              socket: this, 
                                             request: request, 
                                            response: response
                                        }));
                                        
                                        queue();
                                        break;
                                    }
                                }
                                
                                _current.identify();
                                _current._request = null;
                            }
                            else
                            {
                                _state = PENDING_NEXT;
                                _timers.start(TIMER_TIMEOUT_NAME, _settings.connection.timeout, 0, true);
                                
                                /**
                                 * We haven't completed response yet, but
                                 * have read the buffer completely.
                                 */
                                /*if (buffer.bytesAvailable == 0)
                                {
                                    switch (_current.code)
                                    {
                                        case 200:                                                            // OK
                                        case 201:                                                            // Created
                                        {
                                            dispatchEvent(new HTTPSocketEvent(HTTPSocketEvent.DATA, 
                                            {
                                                  socket: this, 
                                                 request: request, 
                                                response: response
                                            }));
                                        }
                                    }
                                }
                                else
                                {
                                    
                                    return;
                                }*/
                            }
                        }
                        else
                        {
                            dispatchEvent(new HTTPSocketEvent(HTTPSocketEvent.SUPERFLUOUS, 
                            {
                                socket: this,
                                buffer: E.clone(buffer)
                            }));
                            break;
                        }
                    }
                    
                    break;
                }
                
                case Event.CONNECT:
                {
                    _state = IDLE;
                    queue();
                    break;
                }
                
                case Event.CLOSE:
                {
                    if (_current._code > 100)
                    {
                        _timers.stop(TIMER_TIMEOUT_NAME);
                        
                        if (_current._encoded)
                        {
                            HTTPEncoding.decode(_current);
                            HTTPContent.decode(_current);
                        }
                        
                        response = _pending.shift();
                        response.identify(_current);
                        
                        _current.identify();
                        _current._request = null;
                        dispatchEvent(new HTTPSocketEvent(HTTPSocketEvent.COMPLETE, 
                        {
                              socket: this, 
                             request: response._request, 
                            response: response
                        }));
                    }
                    dispatchEvent(new HTTPSocketEvent(HTTPSocketEvent.CLOSE, { socket: this }));
                    break;
                }
            }
        }
        
        private function timersEventHandler(event:TimersEvent):void 
        {
            switch (event.name)
            {
                case TIMER_TIMEOUT_NAME:
                {
                    // Server does not answer.
                    break;
                }
                case TIMER_CONTINUE_NAME:
                {
                    if (_state == PENDING_CONTINUE)
                    {
                        _timers.stop(TIMER_CONTINUE_NAME);
                        _state = PENDING_SUCCESS;
                        push(_pending[0]._request._encoded);
                    }
                    break;
                }
            }
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
    
        public function get connected():Boolean
        {
            return _socket && _socket.connected;
        }
        
        public function get settings():HTTPSettings 
        { 
            return _settings; 
        }
        
        public function get state():int 
        { 
            return _state; 
        }
        
        public function get host():String 
        { 
            return _host; 
        }
        
        public function get port():int 
        { 
            return _port; 
        }
        
        /**
         * The responses that have been sent and awaiting 
         * for an answer.
         */
        public function get pendings():Vector.<HTTPRequest> 
        {
            var result:Vector.<HTTPRequest> = new Vector.<HTTPRequest>;
            for (var i:int = 0; i < _pending.length; i++) 
                result.push(_pending[i]._request);
            return result; 
        }
        
        /**
         * The responses that have not been sent yet.
         */
        public function get queued():Vector.<HTTPRequest> 
        { 
            return _queue.slice();
        }
    }
}