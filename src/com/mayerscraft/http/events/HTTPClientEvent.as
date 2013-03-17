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
package com.mayerscraft.http.events 
{
    import com.mayerscraft.events.DataEvent;
    import flash.events.Event;
    
    /**
     * 
     * @author Artyom Goncharov 13.12.2012 18:55
     */
    public class HTTPClientEvent extends DataEvent 
    {
        public static const TERMINATED :String = 'terminated';
        public static const REDIRECT   :String = 'redirect';
        public static const RETRY      :String = 'retry';
        public static const WARNING    :String = 'warning';
        public static const ERROR      :String = 'error';
        public static const DATA       :String = 'data';
        public static const COMPLETE   :String = 'complete';
        
        public function HTTPClientEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) 
        { 
            super(type, data, bubbles, cancelable);
        } 
        
        public override function clone():Event 
        { 
            return new HTTPClientEvent(type, data, bubbles, cancelable);
        } 
        
        public override function toString():String 
        { 
            return formatToString('HTTPClientEvent', 'type', 'bubbles', 'cancelable', 'eventPhase'); 
        }
    }
}