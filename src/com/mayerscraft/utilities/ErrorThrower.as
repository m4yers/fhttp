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
    import com.mayerscraft.lang.EString;

    /**
     * 
     * @author Artyom Goncharov 20.02.2012 11:35
     */
    public final class ErrorThrower
    {
        public static function throwCustomError(string:String):void
        {
            throw 'ERROR: ' + string;
        }
        
        public static function throwCannotChangeObjectInSubject(place:String, object:*, subject:*):void
        {
            throw EString.format("{0} ERROR: One cannot simply change '{1}' in '{2}'", place, object, subject);
        }
        
        public static function throwWrongNumberOfArguments(place:String, method:String, needed:String, received:String):void
        {
            throw place + ' ERROR: ' + ' Wrong number of arguments, needed: ' + needed + ', received: ' + received;
        }
        
        public static function throwMethodIsNotOverridden(place:String, name:String):void
        {
            throw place + ' ERROR: ' + ' \'' + name + '\' method is not overridden.';
        }
        
        public static function throwPropertyIsNull(place:String, name:String):void
        {
            throw place + ' ERROR: ' + ' \'' + name + '\' property is null.';
        }
        
        public static function throwParameterIsWrong(place:String, name:String, why:String = ''):void
        {
            throw place + ' ERROR: ' + ' \'' + name + '\' parameter is wrong, reason: ' + why;
        }
        
        public static function throwParametersWrongType(place:String, name:String, neededType:String, receivedType:String):void
        {
            throw place + ' ERROR: ' + ' \'' + name + '\' parameter\'s type is wrong, needed: ' + neededType, ', received: ' + receivedType;
        }
        
        public static function throwParameterIsNull(place:String, name:String):void
        {
            throw place + ' ERROR: ' + ' \'' + name + '\' parameter is null.';
        }
        
        public static function throwIllegalOperation(place:String, why:String):void
        {
            throw place + ' ERROR: ' + ' Illegal operation because ' + why;
        }
        
        public static function throwUnauthorizedOperation(place:String, why:String):void
        {
            throw place + ' ERROR: ' + ' Unauthorized operation because ' + why;
        }
        
        public static function throwCannotInitializeObjectTwice(place:String):void
        {
            throw place + ' ERROR: ' + ' One cannot simply initialize object twice.';
        }
        
        public static function throwCannotFinalizeObjectTwice(place:String):void
        {
            throw place + ' ERROR: ' + ' One cannot simply finalize object twice.';
        }
        
        public static function throwClassIsSingleton(place:String):void
        {
            throw place + ' ERROR: ' + ' One cannot simply instantiate singleton';
        }
    }
}