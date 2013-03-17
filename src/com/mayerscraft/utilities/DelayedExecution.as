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
package com.mayerscraft.utilities 
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    /**
     * 
     * @author Artyom Goncharov 11.10.2012 16:29
     */
    public class DelayedExecution 
    {
        private static var _initialized  :Boolean;
        private static var _timer        :Timer;
        private static var _items        :Vector.<DelayedExecutionItem>;
        
        public static function register(func:Function, args:Array, delay:Number):void
        {
            if (func != null)
            {
                if (isNaN(delay) || delay == 0.0)
                {
                    func.apply(null, args);
                }
                else
                {
                    if (!_initialized) initialize();
                    _items.push(new DelayedExecutionItem(func, args, delay));
                    if (!_timer.running)
                        _timer.start();
                }
            }
        }
        
        private static function initialize():void
        {
            _timer = new Timer(20.0);
            _timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, false);
            _items = new Vector.<DelayedExecutionItem>();
            _initialized = true;
        }
        
        private static function timerHandler(event:TimerEvent):void 
        {
            for (var i:int = 0; i < _items.length; i++) 
            {
                var 
                item:DelayedExecutionItem = _items[i];
                item.delay -= _timer.delay;
                if (item.delay <= 0.0)
                {
                    item.func.apply(null, item.args);
                    _items.splice(i, 1);
                    i--;
                }
            }
            
            if (_items.length == 0)
                _timer.stop();
        }
    }
}

internal class DelayedExecutionItem
{
    public var func        :Function;
    public var args        :Array;
    public var delay    :Number;
    
    public function DelayedExecutionItem(func:Function, args:Array, delay:Number)
    {
        this.func  = func;
        this.args  = args;
        this.delay = delay;
    }
}