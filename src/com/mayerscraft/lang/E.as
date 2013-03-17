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
    import com.adobe.net.URI;
    import com.mayerscraft.utilities.Asserts;
    import flash.utils.ByteArray;
    
    /**
     * 
     * @author Artyom Goncharov 11.03.2013 11:03
     */
    public class E 
    {
        public static function proxy(f:Function, context:*):Function
        {
            return function(...args):* { f.apply(context, args) };
        }
        
        /**
         * Creates a new instance of specified Object or primitive value. If the 
         * argument is an Object the new instance will be created and returned 
         * as result basing on it's constructo property, argument will be return 
         * as the result otherwise. The method DO NOT clone, it just create 
         * similar type instance.
         * 
         * NOTE. If you want to clone an instance from externaally loaded SWF 
         * you MUST make linkage of the class of the instance in its FLA file 
         * and export that class to ActioScript. Base class instance will be 
         * created otherwise(e.g. MovieClip).
         * 
         * @param something An instance or primitive value.
         * 
         * @return Returns similar instance or primitive value.
         */
        public static function similar(something:*):*
        {
            if (something && something is Object)
                try { return new (Object(something).constructor); } catch (error:Error) { }
            return something;
        }
        
        /**
         * Clones the argument basing on its type. If the argument is 
         * immutable(primitive) the argument will be returned as the result. If 
         * the argument is a ByteArray a new ByteArray instance will be created 
         * and filled with specified data. Array like instances will be cloned 
         * and theirs conten will be cloned recursively as well. The rest of
         * type(Object and its subclasses) will be cloned recursively.
         * 
         * @param value An instance or primitive value.
         * 
         * @return Returns cloned instance or primitive value.
         */
        public static function clone(value:*):*
        {
            if (isImmutable(value))
            {
                return value;
            }
            else if ('clone' in value && value.clone is Function)
            {
                try
                {
                    return value.clone();
                }
                catch (e:Error)
                {
                }
            }
            
            if (value is URI)
            {
                var 
                uri:URI = new URI();
                uri.copyURI(value);
                return uri;
            }
            else if (value is ByteArray)
            {
                var bytes:ByteArray = new ByteArray();
                var pos:int = value.position;
                value.position = 0;
                value.readBytes(bytes, 0, value.bytesAvailable)
                value.position = pos;
                bytes.position = 0;
                return bytes;
            }
            else if (value is Date)
            {
                var 
                date:Date = new Date();
                date.setTime(value.getTime());
                return date;
            }
            else if (EArray.isArray(value))
            {
                var array:* = similar(value);
                for (var i:int = 0; i < value.length; i++) 
                    array.push(clone(value[i]));
                return array;
            }
            else if (value is Object)
            {
                var object:Object = similar(value);
                for (var name:String in value) 
                    object[name] = clone(value[name]);
                return object;
            }
            
            return value;
        }
        
        /**
         * The Identify method tries to copy field members of the source object 
         * to destination object. Correctly works with:
         *      -ByteArray
         *      -Object
         * 
         * @param destination   Desination link.
         * @param source        Source link.
         * 
         * @return Returns destination link.
         */
        public static function identify(destination:*, source:* = null):Object
        {
            Asserts.notNull(destination);
            Asserts.notPrimitive(destination);
                            
            if (destination is ByteArray)
            {
                destination.clear();
                if (source && Asserts.isTypeOf(ByteArray, source))
                {
                    var position:int = source.position;
                    source.position = 0;
                    source.readBytes(destination);
                    source.position = position;
                }
                
            }
            else if (destination is Date)
            {
                destination.setTime(0);
                if (source && Asserts.isTypeOf(Date, destination, source))
                {
                    destination.setTime(source.getTime());
                }
            }
            else if (EArray.isArray(destination))
            {
                Asserts.has(destination, 'fixed', false, undefined, null);
                destination.length = 0;
                if (source && EArray.isArray(source))
                {
                    for (var i:int = 0; i < source.length; i++) 
                        destination[i] = source[i];
                }
            }
            else if (destination is Object)
            {
                var name:String;
                
                for (name in destination) 
                    delete destination[name];
                    
                if (source && Asserts.isTypeOf(Object, destination, source))
                {
                    for (name in source) 
                        destination[name] = source[name];
                }
            }
            
            return destination;
        }
        
        /**
         * Extends 'object' by properties of 'source'.
         * 
         * @param object    Object to be extend.
         * @param source    Object to be extend with.
         * @param cloning   Specifies whether cloning should be used.
         * 
         * @return Returns passed object.
         */
        public static function extend(object:Object, source:Object, cloning:Boolean = false):Object
        {
            Asserts.notNull(object, source);
            
            var name:String;
            
            if (cloning)
            {
                for (name in source) 
                    object[name] = clone(source[name]);
            }
            else
            {
                for (name in source) 
                    object[name] = source[name];
            }
            
            return object;
        }
        
        /**
         * Checks whether 'a' and 'b' are of the same type.
         * 
         * @param a Any value.
         * @param b Any value.
         * 
         * @return  Returns TRUE if 'a' and 'b' are of the same type.
         */
        public static function isSimilarType(a:*, b:*):Boolean
        {
            return Object(a).constructor == Object(b).constructor;
        }
        
        /**
         * Checks whether 'value' is immutable, i.e you cannot change such value 
         * in any way.
         * 
         * @param value Any value.
         * 
         * @return Returns TRUE if 'value' is immutable.
         */
        public static function isImmutable(value:*):Boolean
        {
            return value == undefined || value == null || value is Number || value is int || value is uint || value is String || value is Boolean || value is Function || value is Class;
        }
        
        /**
         * Checks whether 'value' is immutable type, i.e you cannot  change 
         * instance of 'value' in any way.
         * 
         * @param value Any class.
         * 
         * @return Returns TRUE if 'value' is immutable type.
         */
        public static function isImmutableType(value:Class):Boolean
        {
            return value == Number || value == int || value == uint || value == String || value == Boolean || value == Function || value == Class;
        }
        
        /**
         * Checks whether 'value' is primitive.
         * 
         * @param  value Any value.
         * 
         * @return Returns TRUE if 'value' is primitive.
         */
        public static function isPrimitive(value:*):Boolean
        {
            return value is Number || value is int || value is uint || value is String || value is Boolean;
        }
        
        /**
         * Checks whether 'value' is primitive type.
         * 
         * @param value Any value.
         * 
         * @return Returns TRUE if 'value' is primitive type.
         */
        public static function isPrimitiveType(value:Class):Boolean
        {
            return value == Number || value == int || value == uint || value == String || value == Boolean;
        }
        
        /**
         * Checks whether 'value' is simple object, i.e instance of Object.
         * 
         * @param value Any value.
         * 
         * @return Returns TRUE if 'value' is simple object.
         */
        public static function isSimpleObject(value:*):Boolean
        {
            return value is Object && Object(value).constructor === Object;
        }
        
        public static function isDynamic(object:Object):Boolean
        {
            try
            {
                object['__temp'] = true;
            }
            catch (e:Error)
            {
                return false;
            }
            
            delete object['__temp'];
            return true;
        }
    
    //--------------------------------------------------------------------------
    //
    //  Misc
    //
    //--------------------------------------------------------------------------
    
        /**
         * The method generates unique 32 hex digit identificator
         * 
         * @return Returns unique identificator.
         */
        public static function guid():String
        {
            var result:String = '';
            var template:String = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx';
            
            for (var i:int = 0; i < template.length; i++) 
            {
                var c:String = template.substr(i, 1);
                if (c == '-')
                {
                    result += c;
                    continue;
                }
                
                var r:int = Math.random() * 16 | 0;
                var v:int = c == 'x' ? r : (r & 0x3 | 0x8);
                result += v.toString(16);
            }
            
            return result.toUpperCase();
        }
    }
}