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
     * @author Artyom Goncharov 02.03.2013 19:53
     */
    public class HTTPCode 
    {
        public static const _100_CONTINUE                :int = 100;
        public static const _100_SWITCHING_PROTOCOLS     :int = 101;
        
        public static const _200_OK                      :int = 200;
        public static const _201_CREATED                 :int = 201;
        public static const _202_ACCEPTED                :int = 202;
        public static const _203_NON_AUTHORITATIVE       :int = 203;
        public static const _204_NO_CONTENT              :int = 204;
        public static const _205_RESET_CONTENT           :int = 205;
        public static const _206_PARTIAL_CONTENT         :int = 206;
        
        public static const _300_MULTIPLE_CHOICES        :int = 300;
        public static const _301_MOVED_PERMANENTLY       :int = 301;
        public static const _302_FOUND                   :int = 302;
        public static const _303_SEE_OTHER               :int = 303;
        public static const _304_NOT_MODIFIED            :int = 304;
        public static const _305_USE_PROXY               :int = 305;
        public static const _306_UNUSED                  :int = 306;
        public static const _307_TEMPORARY_REDIRECT      :int = 307;
        
        public static const _400_BAD_REQUEST             :int = 400;
        public static const _401_UNAUTHORIZED            :int = 401;
        public static const _402_PAYMENT_REQUIRED        :int = 402;
        public static const _403_FORBIDDEN               :int = 403;
        public static const _404_NOT_FOUND               :int = 404;
        public static const _405_METHOD_NOT_ALLOWED      :int = 405;
        public static const _406_NOT_ACCEPTABLE          :int = 406;
        public static const _407_PROXY_AUTH_REQUIRED     :int = 407;
        public static const _408_REQUEST_TIMEOUT         :int = 408;
        public static const _409_CONFLICT                :int = 409;
        public static const _411_LENGTH_REQUIRED         :int = 411;
        public static const _412_PRECONDITION_FAILED     :int = 412;
        public static const _413_ENTITY_TOO_LARGE        :int = 413;
        public static const _414_REQUEST_URI_TOO_LONG    :int = 414;
        public static const _415_UNSUPPORTED_MEDIA_TYPE  :int = 415;
        public static const _416_RANGE_NOT_SATISFIABLE   :int = 416;
        public static const _417_EXPECTATION_FAILED      :int = 417;
        
        public static const _500_INTERNAL_SERVER_ERROR   :int = 500;
        public static const _501_NOT_IMPLEMENTED         :int = 501;
        public static const _502_BAD_GATEWAY             :int = 502;
        public static const _503_SERVICE_UNAVAILABLE     :int = 503;
        public static const _504_GATEWAY_TIMEOUT         :int = 504;
        public static const _505_VERSION_NOT_SUPPORTED   :int = 505;
    }
}