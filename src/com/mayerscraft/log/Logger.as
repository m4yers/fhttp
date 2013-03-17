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
package com.mayerscraft.log 
{
    import com.mayerscraft.lang.EArray;
    import com.mayerscraft.lang.EString;
    import com.mayerscraft.utilities.ErrorThrower;
    
    /**
     * 
     * @author Artyom Goncharov 09.03.2013 18:53
     */
    public class Logger 
    {
    //--------------------------------------------------------------------------
    //
    //  Static
    //
    //--------------------------------------------------------------------------
        private static const STDOUT     :Function = trace;
        private static const DEFAULT    :String = 'default';
        private static const DEBUG      :String = 'debug';
        private static const MESSAGE    :String = 'message';
        private static const ACTION     :String = 'action';
        private static const WARNING    :String = 'warning';
        private static const ERROR      :String = 'error';
        
        private static var _available   :Boolean = false;
        private static var _instances   :Object = {};
        private static var _items       :EArray = new EArray(new Vector.<Object>);
        
        public static function get(id:String):Logger
        {
            _available = true;
           _instances[id] = _instances[id] || new Logger(id)
            _available = false;
            return _instances[id];
        }
        
        public static function on(id:String = null):void
        {
            if (id)
            {
                if (id in _instances)
                    _instances[id].enabled = true; 
            }
            else
            {
                for (var name:String in _instances) 
                    on(name);
            }
        }
        
        public static function off(id:String = null):void
        {
            if (id)
            {
                if (id in _instances)
                    _instances[id].enabled = false; 
            }
            else
            {
                for (var name:String in _instances) 
                    off(name);
            }
        }
        
        public static function custom(type:String, message:String, id:String = DEFAULT):void
        {
            var logger:Logger = _instances[id];
            
            if (logger && !logger.enabled)
                return;
                
            _items.push(
            { 
                   date: new Date,
                   type: type, 
                message: message 
            });
            
            var stdout:Function = logger ? logger.stdout : STDOUT;
            
            if (stdout == null)
                return;
            
         //----------------------------------
         //  FlashDevelop output
         //----------------------------------
            try
            {
                CONFIG::timeStamp;
                 
                 var tcolor:String;
                 switch (type)
                 {
                     case DEBUG     : tcolor = '0'; break;
                     case MESSAGE   : tcolor = '4'; break;
                     case ACTION    : tcolor = '1'; break;
                     case WARNING   : tcolor = '2'; break;
                     case ERROR     : tcolor = '3'; break;
                     default        : tcolor = '1'; break;
                 }
                 
                 stdout(tcolor + ':' +  type.toUpperCase() + ': ' 
                     + message.split('\n').join('\n' + tcolor + ':' 
                         + EString.multiply(' ', type.length + 1)));
             }
         //----------------------------------
         //  default output
         //----------------------------------
             catch(e:Error)
             {
                 stdout(type.toUpperCase() + ': ' 
                     + message.split('\n').join('\n' + tcolor + ':' 
                         + EString.multiply(' ', type.length + 1)));
             }
        }
        
        public static function debug(message:String, id:String = DEFAULT):void
        {
            custom(DEBUG, message, id);
        }
        
        public static function message(message:String, id:String = DEFAULT):void
        {
            custom(DEBUG, message, id);
        }
        
        public static function action(message:String, id:String = DEFAULT):void
        {
            custom(ACTION, message, id);
        }
        
        public static function warning(message:String, id:String = DEFAULT):void
        {
            custom(WARNING, message, id);
        }
        
        public static function error(message:String, id:String = DEFAULT):void
        {
            custom(ERROR, message, id);
        }
        
    //--------------------------------------------------------------------------
    //
    //  Instance
    //
    //--------------------------------------------------------------------------
        public var enabled:Boolean = true;
        public var stdout:Function = STDOUT;
        
        internal var _id:String;
        
        public function Logger(id:String)
        {
            if (!_available)
            {
                ErrorThrower.throwIllegalOperation('Logger', 
                    'You cannot create an Logger object directly, use Logger.get() instead.');
            }
            
            _id = id;
        }
        
        public function custom(type:String, message:String):void
        {
            Logger.custom(type, message, _id);
        }
        
        public function debug(message:String):void
        {
            Logger.debug(message, _id);
        }
        
        public function message(message:String):void
        {
            Logger.message(message, _id);
        }
        
        public function action(message:String):void
        {
            Logger.action(message, _id);
        }
        
        public function warning(message:String):void
        {
            Logger.warning(message, _id);
        }
        
        public function error(message:String):void
        {
            Logger.error(message, _id);
        }
    }
}