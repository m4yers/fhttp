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
     * @author Artyom Goncharov 27.02.2013 19:23
     */
    public class MIME 
    {
        public static const TEXT_PLAIN              :String = 'text/plain';
        public static const TEXT_XML                :String = 'text/xml';
        public static const TEXT_HTML               :String = 'text/html';
        
        public static const MULTIPART_ALTERNATIVE   :String = 'multipart/alternative';
        public static const MULTIPART_DIGEST        :String = 'multipart/digest';
        public static const MULTIPART_FORM_DATA     :String = 'multipart/form-data';
        public static const MULTIPART_PARALLEL      :String = 'multipart/parallel';
        public static const MULTIPART_MIXED         :String = 'multipart/mixed';
        
        public static function decode(bytes:ByteArray, type:String):IMIMEObject
        {
            var values:Object = new HTTPHeader().parse(':' + type).values;
            
            for (var name:String in values) 
            {
                var parameters:Object = values[name].parameters;
                switch (name)
                {
                    case TEXT_PLAIN             : return new MIMEText               ('plain',   null, parameters.charset).decode(bytes);
                    case TEXT_XML               : return new MIMEText               ('xml',     null, parameters.charset).decode(bytes);
                    case TEXT_HTML              : return new MIMEText               ('html',    null, parameters.charset).decode(bytes);
                    case MULTIPART_ALTERNATIVE  : return new MIMEMultipart          ('alternative') .decode(bytes);
                    case MULTIPART_DIGEST       : return new MIMEMultipart          ('digest')      .decode(bytes);
                    case MULTIPART_FORM_DATA    : return new MIMEMultipartFormData  ()              .decode(bytes);
                    case MULTIPART_MIXED        : return new MIMEMultipart          ('mixed')       .decode(bytes);
                    case MULTIPART_PARALLEL     : return new MIMEMultipart          ('parallel')    .decode(bytes);
                    default                     : return new MIMEApplication        ('octet-stream', bytes);
                }
            }
            
            return null;
        }
    }
}