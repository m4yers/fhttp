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
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.utilities.ErrorThrower;
    
    /**
     * 
     * @author Artyom Goncharov 25.02.2013 14:36
     */
    internal class HTTPEncoding 
    {
        public static const TYPE_IDENTITY   :String = 'identity';
        public static const TYPE_GZIP       :String = 'gzip';
        public static const TYPE_COMPRESS   :String = 'compress';
        public static const TYPE_DEFLATE    :String = 'deflate';
        
        private static const ERROR_DEC_FAILED:String = 'Data decompression has failed, reason: {0}';
        
        public static function encode(request:HTTPRequest, type:String):HTTPRequest
        {
            switch (type)
            {
                case TYPE_IDENTITY:
                {
                    request._headers[HTTPHeader.CONTENT_LENGTH] 
                        = new HTTPHeader(HTTPHeader.CONTENT_LENGTH, request._encoded.length.toString());
                    break;
                }
                
                case TYPE_GZIP:
                {
                    request._encoded = GZIP.compress(request._encoded);
                    request._headers[HTTPHeader.CONTENT_ENCODING] 
                        = new HTTPHeader(HTTPHeader.CONTENT_ENCODING, TYPE_GZIP);
                    break;
                }
            }
            
            return request;
        }
        
        public static function decode(response:HTTPResponse):HTTPResponse
        {
            var headers:Object = response._headers;
            
            if (HTTPHeader.CONTENT_ENCODING in headers)
            {
                switch (headers[HTTPHeader.CONTENT_ENCODING].value())
                {
                    case TYPE_GZIP:
                    {
                        var decompressed:Object = GZIP.decompress(response._encoded);
                        if (decompressed.error)
                        {
                            ErrorThrower.throwCustomError(EString.format(ERROR_DEC_FAILED, decompressed.error));
                        }
                        else
                        {
                            response._encoded = decompressed.data;
                            headers[HTTPHeader.CONTENT_LENGTH] 
                                = new HTTPHeader(HTTPHeader.CONTENT_LENGTH, response._encoded.length.toString());
                            delete headers[HTTPHeader.CONTENT_ENCODING];
                        }
                        
                        break;
                    }
                }
            }
            
            return response;
        }
    }
}