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
    import flash.utils.ByteArray;
    /**
     * 
     * @author Artyom Goncharov 25.02.2013 18:54
     */
    public class MIMEText extends MIMEObject 
    {
        private var _charset:String;
        
        public function MIMEText(subtype:String, text:String = null, charset:String = 'utf-8') 
        {
            super('text/' + subtype, { charset: charset }, text);
            _charset = charset;
        }
        
        override public function encode():ByteArray 
        {
            var bytes:ByteArray = new ByteArray;
            bytes.writeMultiByte(_data as String, _charset);
            return bytes;
        }
        
        override public function decode(bytes:ByteArray):IMIMEObject 
        {
            bytes.position = 0;
            try
            {
                _data = bytes.readMultiByte(bytes.length, _charset);
            }
            catch (e:Error)
            {
                _charset = 'utf-8';
                _data = bytes.readMultiByte(bytes.length, _charset);
            }
            return this;
        }
        
        public function get charset():String 
        { 
            return _charset; 
        }
    }
}