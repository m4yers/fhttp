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
    import com.mayerscraft.mime.IMIMEObject;
    import com.mayerscraft.mime.MIME;
    import com.mayerscraft.mime.MIMEMultipart;
    import com.mayerscraft.mime.MIMEText;
    
    /**
     * 
     * @author Artyom Goncharov 25.02.2013 15:02
     */
    public class HTTPContent 
    {
        public static function encode(request:HTTPRequest, boundary:String = null):void
        {
            if (request._data is IMIMEObject)
            {
                var object:IMIMEObject = request._data as IMIMEObject;
                request._encoded = object.encode();
                request._headers[HTTPHeader.CONTENT_TYPE] = object.headers[HTTPHeader.CONTENT_TYPE].clone();
            }
        }
        
        public static function decode(response:HTTPResponse):HTTPResponse
        {
            if (HTTPHeader.CONTENT_TYPE in response._headers)
                response._data = MIME.decode(response._encoded, response._headers[HTTPHeader.CONTENT_TYPE].value());
                
            if (!response._data)
                response._data = response._encoded;
            
            return null;
        }
    }
}