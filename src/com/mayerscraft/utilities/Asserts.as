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
    import com.mayerscraft.lang.E;
    import com.mayerscraft.lang.EArray;
    
    /**
     * 
     * @author Artyom Goncharov 27.12.2012 14:51
     */
    public class Asserts 
    {
        public static function isNull(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (values[i])
                    notify('Some of the values are not null');
            }
            return true;
        }
        
        public static function notNull(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (!values[i])
                    notify('Some of the values are null');
            }
            return true;
        }
        
        public static function isNAN(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (!isNaN(values[i]))
                    notify('Some of the values are not NaN');
            }
            return true;
        }
        
        public static function notNAN(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (isNaN(values[i]))
                    notify('Some of the values are NaN');
            }
            return true;
        }
        
        public static function isPrimitive(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (!E.isPrimitive(values[i]))
                    notify('Some of the values are non-primitive');
            }
            return true;
        }
        
        public static function notPrimitive(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (E.isPrimitive(values[i]))
                    notify('Some of the values are primitive');
            }
            return true;
        }
        
        public static function isArray(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (!EArray.isArray(values[i]))
                    notify('Some of the values are non-array-like');
            }
            return true;
        }
        
        public static function notArrayLike(...values):Boolean
        {
            for (var i:int = 0; i < values.length; i++) 
            {
                if (EArray.isArray(values[i]))
                    notify('Some of the values are array-like');
            }
            return true;
        }
        
        public static function isDynamic(object:Object):Boolean
        {
            try
            {
                object['__temp'] = true;
            }
            catch (e:Error)
            {
                notify(String(object) + ' is not dynamic');
            }
            
            delete object['__temp'];
            return true;
        }
        
        public static function notDynamic(object:Object):Boolean
        {
            try
            {
                object['__temp'] = true;
            }
            catch (e:Error)
            {
                return true;
            }
            
            notify(String(object) + ' is dynamic');
            return true;
        }
        
        public static function isObjectOf(object:Object, ...types):Boolean
        {
            for (var i:int = 0; i < types.length; i++) 
            {
                if (!(object is (types[i])))
                    notify(String(object) + ' is of an inappropriate type.' );
            }
            
            return true;
        }
        
        public static function isTypeOf(type:Class, ...objects):Boolean
        {
            for (var i:int = 0; i < objects.length; i++) 
            {
                if (!(objects[i] is type))
                    notify(String(type) + ' is not type of ' + String(objects[i]) + '\'' );
            }
            
            return true; 
        }
        
        public static function has(object:Object, field:String, ...values):Boolean
        {
            if (field in object)
            {
                if (values.length > 0 && values.indexOf(object[field]) == -1)
                    notify(String(object) + ' has field \'' + field + '\' but with value \'' + String(object[field]) + '\'');
            }
            else
            {
                notify(String(object) + ' do not have field ' + field);
            }
            
            return true;
        }
        
        public static function isEqualToZero(value:*):Boolean
        {
            value != 0 && notify(value + 'is not eaqual to zero');
            return true;
        }
        
        public static function isBiggerThanZero(value:*):Boolean
        {
            value <= 0 && notify(value + 'is not bigger than to zero');
            return true;
        }
        
        public static function isMinMax(min:Number, max:Number):Boolean
        {
            min >= max && notify(min + ' is not lesser than ' + max); 
            return true;
        }
        
    //----------------------------------
    //  private
    //----------------------------------
        private static function notify(string:String):void
        {
            throw string;
        }
    }
}