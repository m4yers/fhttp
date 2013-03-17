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
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 12:35
     */
    public class HTTPMethod 
    {
        public static const HEAD    :String = 'HEAD';
        public static const OPTIONS :String = 'OPTIONS';
        public static const GET     :String = 'GET';
        public static const POST    :String = 'POST';
        public static const PUT     :String = 'PUT';
        public static const DELETE  :String = 'DELETE';
        public static const TRACE   :String = 'TRACE';
        public static const CONNECT :String = 'CONNECT';
        public static const PATCH   :String = 'PATCH';
        
        internal static const SAFES:Vector.<String> = Vector.<String>
        ([ 
            GET, HEAD,
        ]);
        
        internal static const IDEMPOTENTS:Vector.<String> = Vector.<String>
        ([ 
            GET, HEAD, PUT, DELETE, OPTIONS, TRACE,
        ]);
    }
}