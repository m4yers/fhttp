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
package com.mayerscraft.lang 
{
    /**
     * 
     * @author Artyom Goncharov 24.12.2012 12:12
     */
    public class EDate extends Date
    {
        private static const WEEKDAYS                :Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
        private static const WKDAYS                  :Array = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        private static const MONTHS                  :Array = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        
        private static const TEMPLATE_DATE_RFC1123   :String = '{0}, {2} {1} {6} {3}:{4}:{5} GMT';    // Sun, 06 Nov 1994 08:49:37 GMT
        private static const TEMPLATE_DATE_RFC850    :String = '{0}, {2}-{1}-{6} {3}:{4}:{5} GMT';    // Sunday, 06-Nov-94 08:49:37 GMT
        private static const TEMPLATE_DATE_ANSI_C    :String = '{0} {1} {2} {3}:{4}:{5} {6}';         // Sun Nov  6 08:49:37 1994
        
        private static const REGEXP_DATE_FLASH_UTC   :RegExp = /(\w{3}\b|\b\d{1,2}\b|\d{4})/g;        // [week,month,day,hh,mm,ss,yyyy,"UTC"]
        private static const REGEXP_DATE_RFC1123     :RegExp = /(\w{3}\b|\b\d{2}\b|\d{4})/g;          // [week,day,month,yyyy,hh,mm,ss,"GMT"]
        private static const REGEXP_DATE_RFC1036     :RegExp = /(^\w+|\b\d{2}\b|\w{3})/g;             // [week,day,month,yy,hh,mm,ss,"GMT"]
        private static const REGEXP_DATE_ANSI_C      :RegExp = /(\w{3}\b|\b\d{1,2}\b|\d{4})/g;        // [week,month,day,hh,mm,ss,yyyy]
        
    //----------------------------------
    //  Date
    //----------------------------------
        public static function toDate(string:String):Date
        {
            var result:Date;
            var parts:Array;
            
            if (REGEXP_DATE_RFC1123.test(string))
            {
                parts = string.match(REGEXP_DATE_RFC1123);
                result = new Date(parts[3], MONTHS.indexOf(parts[2]), parts[1], parts[4], parts[5], parts[6]);
            }
            else if (REGEXP_DATE_RFC1036.test(string))
            {
                parts = string.match(REGEXP_DATE_RFC1036);
                result = new Date(parts[3], MONTHS.indexOf(parts[2]), parts[1], parts[4], parts[5], parts[6]);
            }
            else if (REGEXP_DATE_ANSI_C.test(string))
            {
                parts = string.match(REGEXP_DATE_RFC1036);
                result = new Date(parts[6], MONTHS.indexOf(parts[1]), parts[2], parts[3], parts[4], parts[5]);
            }
            
            if (result && isNaN(result.time))
                result = null;
            
            return result;
        }
        
        public static function toRFC1123(date:Date):String
        {
            var 
            parts:Array = date.toUTCString().match(REGEXP_DATE_FLASH_UTC)
            parts[2] = EString.prepend(parts[2], '0', 2 - parts[2].length);
            parts[3] = EString.prepend(parts[3], '0', 2 - parts[3].length);
            parts[4] = EString.prepend(parts[4], '0', 2 - parts[4].length);
            parts[5] = EString.prepend(parts[5], '0', 2 - parts[5].length);
            return EString.format.apply(null, [ TEMPLATE_DATE_RFC1123 ].concat(parts));
        }
        
        public static function toRFC1036(date:Date):String
        {
            var 
            parts:Array = date.toUTCString().match(REGEXP_DATE_FLASH_UTC)
            parts[0] = WEEKDAYS[WKDAYS.indexOf(parts[0])];
            parts[2] = EString.prepend(parts[2], '0', 2 - parts[2].length);
            parts[3] = EString.prepend(parts[3], '0', 2 - parts[3].length);
            parts[4] = EString.prepend(parts[4], '0', 2 - parts[4].length);
            parts[5] = EString.prepend(parts[5], '0', 2 - parts[5].length);
            parts[6] = String(parts[6]).substr(2, 2);
            return EString.format.apply(null, [ TEMPLATE_DATE_RFC850 ].concat(parts));
        }
        
        public static function toANSI_C(date:Date):String
        {
            var 
            parts:Array = date.toUTCString().match(REGEXP_DATE_FLASH_UTC);
            parts[2] = EString.prepend(parts[2], ' ', 2 - parts[2].length);
            parts[3] = EString.prepend(parts[3], '0', 2 - parts[3].length);
            parts[4] = EString.prepend(parts[4], '0', 2 - parts[4].length);
            parts[5] = EString.prepend(parts[5], '0', 2 - parts[5].length);
            return EString.format.apply(null, [ TEMPLATE_DATE_ANSI_C ].concat(parts));
        }
        
        public function EDate(year:*=null, month:*=null, date:*=null, hours:*=null, minutes:*=null, seconds:*=null, ms:*=null)
        {
            super(year, month, date, hours, minutes, seconds, ms);
        }
        
        public function fromHTTP(string:String):EDate
        {
            setTime(toDate(string).time);
            return this;
        }
        
        public function toRFC1123():String
        {
            return EDate.toRFC1123(this);
        }
        
        public function toRFC1036():String
        {
            return EDate.toRFC1036(this);
        }
        
        public function toANSI_C():String
        {
            return EDate.toANSI_C(this);
        }
    }
}