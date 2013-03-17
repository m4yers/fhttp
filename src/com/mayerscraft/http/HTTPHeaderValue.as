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
    /**
     * 
     * @author Artyom Goncharov 26.02.2013 11:36
     */
    public class HTTPHeaderValue
    {
        internal var _token         :String;
        internal var _value         :String;
        internal var _parameters    :Object;
        
        public function HTTPHeaderValue(token:String, value:String = null, parameters:Object = null)
        {
            _token = token;
            _value = value;
            _parameters = parameters;
        }
        
        public function clone():HTTPHeaderValue
        {
            return new HTTPHeaderValue(_token, _value, E.clone(_parameters));
        }
        
        public function get token():String 
        { 
            return E.clone(_token); 
        }
        
        public function get value():String 
        { 
            return E.clone(_value); 
        }
        
        public function get parameters():Object 
        { 
            return E.clone(_parameters); 
        }
    }
}