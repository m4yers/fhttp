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
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 27.02.2013 16:24
     */
    public class MIMEApplicationURLEncoded extends MIMEApplication
    {
        public function MIMEApplicationURLEncoded(data:Object) 
        {
            super('x-www-form-urlencoded', data || { });
        }
        
        override public function encode():ByteArray 
        {
            var string:String = '';
            
            if (E.isArray(_data))
            {
                for (var i:int = 0; i < _data.length; i+=2) 
                    string += '&' + escape(_data[i]) + (_data[i + 1] ? ('=' + escape(_data[i + 1])) : '');
            }
            else
            {
                for (var name:String in _data) 
                    string += '&' + escape(name) + (_data[name] ? ('=' + escape(_data[name])) : '');
            }
            
            string = string.slice(1);
            
            var 
            bytes:ByteArray = new ByteArray;
            bytes.writeUTFBytes(string);
            
            return bytes;
        }
        
        override public function decode(bytes:ByteArray):IMIMEObject 
        {
            _data = { };
            
            var string:String = bytes.toString();
            var pairs:Array = string.split('&');
            for (var i:int = 0; i < pairs.length; i++) 
            {
                var pair:Array = pairs[i].split('=');
                _data[unescape(pair[0])] = unescape(pair[1]);
            }
            
            return this;
        }
    }
}