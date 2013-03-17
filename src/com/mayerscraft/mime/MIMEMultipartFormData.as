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
    import com.mayerscraft.lang.E;
    import flash.utils.ByteArray;
    /**
     * 
     * @author Artyom Goncharov 27.02.2013 13:28
     */
    public class MIMEMultipartFormData extends MIMEMultipart 
    {
        public function MIMEMultipartFormData() 
        {
            super('form-data');
        }
        
        override public function add(object:IMIMEObject, options:Object = null):MIMEMultipart 
        {
            if (object is MIMEMultipartFormData)
                throw new Error('MIMEMultipartFormData cannot be passed here.');
            
            options = options || { };
            
            var parameters:Object = { name: options.name || E.guid() };
            if (object is MIMEMultipart)
            {
                var filenames:Array = options.filenames || [];
                var multipart:MIMEMultipart = object as MIMEMultipart;
                for (var i:int = 0; i < multipart._data.length; i++) 
                {
                    multipart._data[i]._headers[HTTPHeader.CONTENT_DISPOSITION] = 
                        new HTTPHeader(HTTPHeader.CONTENT_DISPOSITION, 'file', null, 
                        {
                            filename: filenames[i] || E.guid()
                        });
                }
            }
            else
            {
                if ('filename' in options)
                    parameters.filename = options.filename;
            }
            
            MIMEObject(object)._headers[HTTPHeader.CONTENT_DISPOSITION] = 
                new HTTPHeader(HTTPHeader.CONTENT_DISPOSITION, 'form-data', null, parameters);
            
            return super.add(object, options);
        }
        
        override public function encode():ByteArray
        {
            var bytes:ByteArray = new ByteArray;
            
            for (var i:int = 0; i < _data.length; i++) 
            {
                var object:IMIMEObject = _data[i];
                bytes.writeByte(HY);
                bytes.writeByte(HY);
                bytes.writeMultiByte(boundary, CHARSET_US_ASCII);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
                bytes.writeMultiByte(object.headers[HTTPHeader.CONTENT_DISPOSITION].full(), CHARSET_US_ASCII);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
                bytes.writeMultiByte(object.headers[HTTPHeader.CONTENT_TYPE].full(), CHARSET_US_ASCII);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
                bytes.writeBytes(object.encode(), 0, 0);
                bytes.writeByte(CR);
                bytes.writeByte(LF);
            }
            
            bytes.writeByte(HY);
            bytes.writeByte(HY);
            bytes.writeMultiByte(boundary, CHARSET_US_ASCII);
            bytes.writeByte(HY);
            bytes.writeByte(HY);
            
            return bytes;
        }
    }
}