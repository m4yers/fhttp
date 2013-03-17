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
    import com.mayerscraft.lang.EArray;
    
    /**
     * 
     * @author Artyom Goncharov 23.02.2013 18:02
     */
    internal class HTTPSettings
    {
        private var _list       :EArray;
        private var _client     :HTTPClientSettings;    
        private var _socket     :HTTPSocketSettings;
        private var _connection :HTTPConnectionSettings;
        private var _pipeline   :HTTPPipelineSettings;
        private var _redirect   :HTTPRedirectSettings;
        private var _retry      :HTTPRetrySettings;
        
        public function HTTPSettings()
        {
            _list       = new EArray;
            _client     = new HTTPClientSettings;
            _socket     = new HTTPSocketSettings;
            _connection = new HTTPConnectionSettings;
            _pipeline   = new HTTPPipelineSettings;
            _redirect   = new HTTPRedirectSettings;
            _retry      = new HTTPRetrySettings;
        }
        
        public function get client():HTTPClientSettings 
        { 
            return _client; 
        }
        
        public function get socket():HTTPSocketSettings 
        { 
            return _socket; 
        }
        
        public function get connection():HTTPConnectionSettings 
        { 
            return _connection; 
        }
        
        public function get pipeline():HTTPPipelineSettings 
        { 
            return _pipeline; 
        }
        
        public function get redirect():HTTPRedirectSettings 
        { 
            return _redirect; 
        }
        
        public function get retry():HTTPRetrySettings 
        { 
            return _retry; 
        }
        
        public function branch():HTTPSettings
        {
            var 
            branch:HTTPSettings = new HTTPSettings;
            
            _list.push(branch);
            
            return branch;
        }
    }
}

internal class HTTPClientSettings
{
    public var name:String = 'fhttp';
    public var verstion:String = '0.5';
    public var started:Boolean;
}

internal class HTTPSocketSettings
{
    public var encoding:String = '';
    public var expectContinue:Boolean = true;
}

internal class HTTPConnectionSettings
{
    private static const PERSISTENT :int = 0; 
    private static const TERMINABLE :int = 1; 
    
    private var _type       :int = PERSISTENT;
    private var _timeout    :int = 60000;
    private var _parallels  :uint = 2;
    private var _density    :uint = 5;
        
    public function persistent():void
    {
        _type = PERSISTENT;
    }
    
    public function terminable():void
    {
        _type = TERMINABLE;
    }
    
    public function get isPersistent():Boolean
    {
        return _type == PERSISTENT;
    }
    
    public function get isTerminable():Boolean
    {
        return _type == TERMINABLE;
    }
    
    public function get timeout():int 
    { 
        return _timeout; 
    }
    
    public function get parallels():uint 
    { 
        return _parallels; 
    }
    
    public function get density():uint 
    { 
        return _density; 
    }
}

internal class HTTPPipelineSettings
{
    private static const NONE  :int = 0;
    private static const SAFE  :int = 1;
    private static const ALL   :int = 2;
    
    private var _type:int = SAFE;
    
    public function none():void
    {
        _type = NONE;
    }
    
    public function safe():void
    {
        _type = SAFE;
    }
    
    public function all():void
    {
        _type = ALL;
    }
    
    public function get isNone():Boolean
    {
        return _type == NONE;
    }
    
    public function get isSafe():Boolean
    {
        return _type == SAFE;
    }
    
    public function get isAll():Boolean
    {
        return _type == ALL;
    }
}

internal class HTTPRedirectSettings
{
    private static const NONE         :int = 0;
    private static const SAFE         :int = 1;
    private static const IDEMPOTENT   :int = 2;
    private static const ALL          :int = 3;
    
    private var _type:int = SAFE;
    
    public function none():void
    {
        _type = NONE;
    }
    
    public function safe():void
    {
        _type = SAFE;
    }
    
    public function idempotent():void
    {
        _type = IDEMPOTENT;
    }
    
    public function all():void
    {
        _type = ALL;
    }
    
    public function get isNone():Boolean
    {
        return _type == NONE;
    }
    
    public function get isSafe():Boolean
    {
        return _type == SAFE;
    }
    
    public function get isIdempotent():Boolean
    {
        return _type == IDEMPOTENT;
    }
    
    public function get isAll():Boolean
    {
        return _type == ALL;
    }
}

internal class HTTPRetrySettings
{
    private static const NONE        :int = 0;
    private static const SAFE        :int = 1;
    private static const IDEMPOTENT  :int = 2;
    private static const ALL         :int = 3;
    
    private var _type:int = SAFE;
    
    public function none():void
    {
        _type = NONE;
    }
    
    public function safe():void
    {
        _type = SAFE;
    }
    
    public function idempotent():void
    {
        _type = IDEMPOTENT;
    }
    
    public function all():void
    {
        _type = ALL;
    }
    
    public function get isNone():Boolean
    {
        return _type == NONE;
    }
    
    public function get isSafe():Boolean
    {
        return _type == SAFE;
    }
    
    public function get isIdempotent():Boolean
    {
        return _type == IDEMPOTENT;
    }
    
    public function get isAll():Boolean
    {
        return _type == ALL;
    }
}