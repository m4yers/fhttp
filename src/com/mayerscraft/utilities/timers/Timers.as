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
package com.mayerscraft.utilities.timers 
{
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.utilities.ErrorThrower;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    
    /**
     * 
     * @author Artyom Goncharov 28.12.2012 11:02
     */
    [Event(name="timer",           type="com.mayerscraft.utilities.timers.TimersEvent")] 
    [Event(name="timer_complete",  type="com.mayerscraft.utilities.timers.TimersEvent")] 
    public class Timers extends EventDispatcher
    {
        private var _timers:Object = { };
        
        public function Timers() 
        {
        }
        
        public function start(name:String, delay:Number, repeatCount:int = 0, replace:Boolean = false):void
        {
            if (has(name) && replace)
            {
                ErrorThrower.throwIllegalOperation(toString(), 'One cannot simply create create timer twice');
            }
            else
            {
                stop(name);
                
                var 
                timer:NamedTimer = new NamedTimer(name, delay, repeatCount);
                timer.addEventListener(TimerEvent.TIMER,           timerEventHandler, false, 0, false);
                timer.addEventListener(TimerEvent.TIMER_COMPLETE,  timerEventHandler, false, 0, false);
            }
        }
        
        public function stop(name:String = null):void
        {
            if (name)
            {
                var timer:NamedTimer = _timers[name];
                if (timer)
                {
                    timer.removeEventListener(TimerEvent.TIMER,           timerEventHandler, false);
                    timer.removeEventListener(TimerEvent.TIMER_COMPLETE,  timerEventHandler, false);
                    timer.stop();
                    
                    _timers[name] = null;
                    delete _timers[name];
                }
            }
            else
            {
                for (var name:String in _timers) 
                    stop(name);
            }
        }
        
        public function has(name:String):Boolean
        {
            return name in _timers;
        }
        
        override public function toString():String
        {
            return EString.toString(this, 'Timers');
        }
        
    //--------------------------------------------------------------------------
    //
    //  Handlers
    //
    //--------------------------------------------------------------------------
        
        private function timerEventHandler(event:TimerEvent):void 
        {
            var timer:NamedTimer = event.target as NamedTimer;
            switch (event.type)
            {
                case TimerEvent.TIMER:
                {
                    dispatchEvent(new TimersEvent(TimersEvent.TIMER, timer.name));
                    break;
                }
                case TimerEvent.TIMER_COMPLETE:
                {
                    dispatchEvent(new TimersEvent(TimersEvent.TIMER_COMPLETE, timer.name));
                    stop(timer.name);
                    break;
                }
            }
        }
    }
}