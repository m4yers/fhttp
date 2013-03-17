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
    import com.mayerscraft.utilities.Asserts;
    import com.mayerscraft.utilities.Sortings;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Dictionary;
    import flash.utils.flash_proxy;
    import flash.utils.getQualifiedClassName;
    import flash.utils.Proxy;
    
    /**
     * 
     * @author Artyom Goncharov 07.03.2013 13:17
     */
    dynamic public class EArray extends Proxy
    {
    //--------------------------------------------------------------------------
    //
    //  Static
    //
    //--------------------------------------------------------------------------
        private static const IS_ARRAY_REGEXP:RegExp = /__AS3__.vec::Vector.<[\w\.:]+>/
        private static const IS_ARRAY_MEMEBRS:Array = 
        [ 
            'length', 'concat', 'push', 'pop', 'shift', 'unshift', 
            'indexOf', 'lastIndexOf', 'reverse', 'slice', 'splice'
        ];
        
        /**
         * Checks whether the argument is an Array like object.
         * 
         * @param array An Object instance.
         * 
         * @return Returns TRUE if the argument is an Array like object.
         */
        public static function isArray(array:*):Boolean
        {
            if (!array)
                return false;
            
            if (array is Array)
                return true;
                
            if (getQualifiedClassName(array).match(IS_ARRAY_REGEXP))
                return true;
                
            for (var i:int = 0, l:int = IS_ARRAY_MEMEBRS.length; i < l; i++) 
                if (!(IS_ARRAY_MEMEBRS[i] in array))
                    return false;
            
            return true;
        }
        
        /**
         * The method returns a new list containing all the items that are in 
         * either list.
         * 
         * @param a Array like instance.
         * @param b Array like instance.
         * @param strict Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns a new list containing all the items that are in 
         * either list.
         */
        public static function union(a:*, b:*, strict:Boolean = false):*
        {
            Asserts.isArray(a, b);
            return intersection(a, b, strict).concat(symmetricDifference(a, b, strict));
        }
    
        /**
         * The method compares items in both lists against each other and if 
         * they match pushes to result array.
         * 
         * @param a Array like instance.
         * @param b Array like instance.
         * @param strict Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns an Array with items that enlisted in both lists.
         */
        public static function intersection(a:*, b:*, strict:Boolean = false):*
        {
            Asserts.isArray(a, b);
            
            var result:* = E.isSimilarType(a, b) ? E.similar(a) : [];
            var i:int;
            var j:int;
            
            if (strict)
            {
                for (i = 0; i < a.length; i++) 
                {
                    for (j = 0; j < b.length; j++) 
                    {
                        if (a[i] === b[j])
                            result.push(a[i]);
                    }
                }
            }
            else
            {
                for (i = 0; i < a.length; i++) 
                {
                    for (j = 0; j < b.length; j++) 
                    {
                        if (a[i] == b[j])
                            result.push(a[i]);
                    }
                }
            }
            
            return result;
        }
        
        /**
         * The method returns a new list containing all the items that are in 
         * 'list' but not 'from'.
         * 
         * @param a        Array like instance.
         * @param b        Array like instance.
         * @param strict   Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns a new list containing all the items that are in 'list' 
         * but not 'from'.
         */
        public static function difference(list:*, from:*, strict:Boolean = false):*
        {
            Asserts.isArray(list, from);
            
            var result:* = E.isSimilarType(list, from) ? E.similar(list) : [];
            var i:int;
            var j:int;
            
            if (strict)
            {
                lds:for (i = 0; i < list.length; i++) 
                {
                    for (j = 0; j < from.length; j++) 
                        if (list[i] === from[j])
                            continue lds;
                    
                    result.push(list[i]);
                }
            }
            else
            {
                ld:for (i = 0; i < list.length; i++) 
                {
                    for (j = 0; j < from.length; j++) 
                        if (list[i] == from[j])
                            continue ld;
                    
                    result.push(list[i]);
                }
            }
            
            return result;
        }
        
        /**
         * The method returns a new list containing all the items that are in
         * exactly one of the listss.
         * 
         * @param a         Array like instance.
         * @param b         Array like instance.
         * @param strict    Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns a new list containing all the items that are in 
         * exactly one of the listss.
         */
        public static function symmetricDifference(a:*, b:*, strict:Boolean = false):*
        {
            Asserts.isArray(a, b);
            return difference(a, b, strict).concat(difference(b, a, strict))
        }
        
        /**
         * Generates new list basing on the arguments lists values' string
         * representations concatenated each to each, resulting in list of NxM 
         * items.
         * 
         * @param a Array like instance.
         * @param b Array like instance.
         * 
         * @return Returns new Array based on the argument array's items.
         */
        public static function conjunction(a:*, b:*):*
        {
            if (!EArray.isArray(a))
                a = [a];
                
            if (!EArray.isArray(b))
                b = [b];
            
            var result:Array = E.isSimilarType(a, b) ? E.similar(a) : [];
            var i:int;
            var j:int;
                
            for (i = 0; i < a.length; i++) 
            {
                for (j = 0; j < b.length; j++) 
                    result.push(String(a[i]) + String(b[j]));
            }
            
            return result;
        }
        
        /**
         * The method checks whether 'subset' is part of 'set'.
         * 
         * @param set    Set to be campared with
         * @param subset Subset to be checked
         * 
         * @retur Returns True if 'subset' is part of 'set'.
         */
        public static function isSubset(set:Array, subset:Array, strict:Boolean = false):Boolean
        {
            Asserts.isArray(set, subset)
            
            var i:int;
            var j:int;
            
            if (strict)
            {
                isss:for (i = 0; i < subset.length; i++) 
                {
                    for (j = 0; j < set.length; j++) 
                    {
                        if (subset[i] === set[j])
                            continue isss;
                    }
                    return false;
                }
            }
            else
            {
                iss:for (i = 0; i < subset.length; i++) 
                {
                    for (j = 0; j < set.length; j++) 
                    {
                        if (subset[i] == set[j])
                            continue iss;
                    }
                    return false;
                }
            }
            
            return true;
        }
        
        public static function sort(array:*, field:String = null, reverse:Boolean = false):*
        {
            return Sortings.insertion(array, field, reverse);
        }
        
        /**
         * Searches the array for specified value or property and value.
         * 
         * @param array     Array like instance.
         * @param value     Desired value.
         * @param property  Desired property.
         * @param indices   If true, indices will be returned, items otherwise.
         * 
         * @return Return depends on returnIndices flag. If true, index will be 
         * returned, item otherwise.
         */
        public static function search(array:*, value:*, property:String = null, indices:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var result:* = E.similar(array);
            var i:int;
            var l:int
            
            if (property && property != '')
            {
                for (i = 0, l = array.length; i < l; i++) 
                    if (array[i] && array[i][property] == value)
                        result.push(indices ? i : array[i]);
            }
            else 
            {
                for (i = 0, l = array.length; i < l; i++) 
                    if (array[i] == value)
                        result.push(indices ? i : array[i]);
            }
            
            return result;
        }
        
        private static const WILD_SINGLE_SIGN    :String = '*';
        private static const WILD_SINGLE_REGEXP  :String = '[\\d\\w_]';
        private static const WILD_MULTI_SIGN     :String = '~';
        private static const WILD_MULTI_REGEXP   :String = '[\\d\\w_]*?';
        
        /**
         * 
         * @param selectors
         * @param array
         * @param inverse
         * @return
         */
        public static function indices(array:*, selectors:*, inverse:Boolean = false):Array
        {
            Asserts.isArray(array);
            
            selectors = EArray.isArray(selectors) ? selectors : [ selectors ];
            
            var result    :Array = [];
            var item    :*;
            var i        :int;
            var j        :int;
            var l        :int;    // len
            var k        :int;    // len
            
            if (selectors.length == 0)
            {
                result.concat(array);
            }
            else
            {
                for (j = 0, l = selectors.length; j < l; j++) 
                {
                    var selector:* = selectors[j];
                //----------------------------------
                //  String
                //----------------------------------
                    if (selector is String)
                    {
                        var string:String = selector as String;
                        if (string.slice(0, 1) == ':')
                        {
                            var indices:Array = string.slice(1).split(',');
                            for (i = 0, k = indices.length; i < k; i++)
                            {
                                if (indices[i].indexOf('-') == -1)
                                    result.push(indices[i]);
                                else
                                    result.push.apply(result, EMath.rangeInt.apply(null, indices[i].split('-')));
                            }
                            
                        }
                        else
                        {
                            string = string.replace(WILD_SINGLE_SIGN, WILD_SINGLE_REGEXP);
                            string = string.replace(WILD_MULTI_SIGN,  WILD_MULTI_REGEXP);
                            selector = RegExp('^' + string + '$');
                        }
                    }
                    
                //----------------------------------
                //  RegExp
                //----------------------------------
                    if (selector is RegExp)
                    {
                        for (i = 0, k = array.length; i < k; i++) 
                        {
                            item = array[i];
                            if (('name' in item && item.name.match(selector)) || String(item).match(selector))
                                result.push(i);
                        }
                    }
                //----------------------------------
                //  Class
                //----------------------------------
                    else if (selector is Class)
                    {
                        for (i = 0, k = array.length; i < k; i++) 
                        {
                            item = array[i];
                            if (item is selector)
                                result.push(i);
                        }
                    }
                //----------------------------------
                //  Function
                //----------------------------------
                    else if (selector is Function)
                    {
                        for (i = 0, k = array.length; i < k; i++) 
                        {
                            item = array[i];
                            if (selector.call(item, item, i))
                                result.push(i);
                        }
                    }
                //----------------------------------
                //  Object
                //----------------------------------
                    else if (E.isSimpleObject(selector))
                    {
                        outer:for (i = 0, k = array.length; i < k; i++)  
                        {
                            item = array[i];
                            if (item)
                            {
                                for (var name:String in selector) 
                                {
                                    if (!(name in item) || selector[name] != item[name])
                                        continue outer;
                                }
                                result.push(i);
                            }
                        }
                    }
                //----------------------------------
                //  Default
                //----------------------------------
                    else
                    {
                        for (i = 0, k = array.length; i < k; i++)  
                        {
                            item = array[i];
                            if (item == selector)
                                result.push(i);
                        }
                    }
                }
                
                if (inverse)
                {
                    var inversed:Array = [ ];
                    for (i = 0; i < array.length; i++) 
                    {
                        if (result.indexOf(i) == -1)
                            inversed.push(i);
                    }
                    result = inversed;
                }
            }
                
            return unique(result, selectors.length);
        }
        
        /**
         * The method returns TRUE if encounters an item that match the selector.
         * 
         * @param array
         * @param selectors
         * @param inverse
         * @return
         */
        public static function has(array:*, selectors:*, inverse:Boolean = false):Boolean
        {
            return indices(array, selectors, inverse).length != 0;
        }
        
        /**
         * The method goes through the array and counts 'value' that he 
         * encounters.
         * 
         * @param array
         * @param selectors
         * @param inverse
         * @return
         */
        public static function count(array:*, selectors:*, inverse:Boolean = false):uint
        {
            return indices(array, selectors, inverse).length;
        }
        
        /**
         * 
         * @param selectors
         * @param array
         * @param inverse
         * @return
         */
        public static function select(array:*, selectors:*, inverse:Boolean = false):*
        {
            var indices:Array = indices(array, selectors, inverse);
            var result:* = E.similar(array);
            for (var i:int = 0; i < indices.length; i++) 
                result[i] = array[indices[i]];
            return result;
        }
        
        public static function filter(array:*, selectors:*, inverse:Boolean = false):*
        {
            var indices:Array = indices(array, selectors, inverse);
            for (var i:int = 0, l:int = indices.length; i < l; i++) 
                array.splice(indices[i] - i, 1);
            return array;
        }
        
        public static function cut(array:*, selectors:*, inverse:Boolean = false):*
        {
            var indices:Array = indices(array, selectors, inverse);
            var result:* = E.similar(array);
            for (var i:int = 0, l:int = indices.length; i < l; i++) 
                result.push(array.splice(indices[i] - i, 1)[0]);
            return result;
        }
        
        /**
         * 
         * @param array
         * @param selector
         * @param ...items
         * @return
         */
        public static function replace(array:*, selector:*, ...items):*
        {
            items.unshift(null, null);
            
            var indices:Array = indices(array, selector);
            for (var i:int = 0; i < indices.length; i++) 
            {
                items[0] = indices[i];
                items[1] = 1;
                array.splice.apply(array, items);
            }
            
            return array;
        }
        
        public static function each(array:*, f:Function, ...args):*
        {
            Asserts.isArray(array);
            Asserts.notNull(f);
        
            args.unshift(null);
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                args[0] = array[i];
                f.apply(null, args);
            }
            
            return array;
        }
        
        public static function map(array:*, f:Function, ...args):Array
        {
            Asserts.isArray(array);
            Asserts.notNull(f);
            
            args.unshift(null);
            var result:Array = [];
            
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                args[0] = array[i];
                result.push(f.apply(null, args));
            }
            
            return result;
        }
        
        public static function zip(array:*, field:String, value:*):* 
        {
            Asserts.isArray(array)
            Asserts.notNull(field);
            
            var item:*;
            var i:int;
            var j:int;
            var l:int;
            
            if (EArray.isArray(value) && value.length > 0)
            {
                for (i = 0, j = 0, l = array.length; i < l; i++) 
                {
                    item = array[i];
                    
                    if (field in item)
                        item[field] = value[j];
                        
                    if (++j == value.length)
                        j = 0;
                }
            }
            else if (E.isSimpleObject(value))
            {
                for (i = 0, l = array.length; i < l; i++) 
                {
                    item = array[i];
                    if (field in item && (String(item) in value || ('name' in item && item.name in value)))
                        item[field] = value[item.name];
                }
            }
            else
            {
                for (i = 0, l = array.length; i < l; i++) 
                {
                    item = array[i];
                    if (field in item)
                        item[field] = value;
                }
            }
            
            return array;
        }
        
        public static function wrap(array:Array, wrapper:Class, silent:Boolean = true):Array
        {
            Asserts.isArray(array);
            Asserts.notNull(wrapper);
            
            var result:Array = [];
            
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                try
                {
                    result.push(new wrapper(array[i]));
                }
                catch (e:Error)
                {
                    if (!silent)
                        throw e;
                }
            }
            
            return result;
        }
        
        public static function cast(array:Array, caster:Class, silent:Boolean = true):Array
        {
            Asserts.isArray(array);
            Asserts.notNull(caster);
            
            var result:Array = [];
            
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                try
                {
                    result.push(caster(array[i]));
                }
                catch (e:Error)
                {
                    if (!silent)
                        throw e;
                }
            }
            
            return result;
        }
        
        public static function object(array:*, field:String):Object
        {
            Asserts.isArray(array);
            Asserts.notNull(field);
            
            var result:Object = { };
            
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                var item:* = array[i];
                if (field in item)
                {
                    var value:String = String(item[field]);
                    if (value in result)
                    {
                        if (result[value] is Array)
                            result[value].push(item);
                        else
                            result[value] = [ result[value], item ];
                    }
                    else
                    {
                        result[value] = item;
                    }
                }
            }
            
            return result;
        }
        
        public static function dictionary(array:*, field:String = null):Dictionary
        {
            Asserts.isArray(array);
            Asserts.notNull(field);
            
            var result:Dictionary = new Dictionary;
            
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                var item:* = array[i];
                if (field in item)
                {
                    var value:* = field ? item[field] : item;
                    if (value in result)
                    {
                        if (result[value] is Array)
                            result[value].push(item);
                        else
                            result[value] = [ result[value], item ];
                    }
                    else
                    {
                        result[value] = item;
                    }
                }
            }
            
            return result;
        }
        
        public static function unique(array:*, edge:int = 1):*
        {
            Asserts.isArray(array);
            
            var result:* = E.similar(array);
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                if (result.indexOf(array[i]) == -1)
                {
                    var count:int = 0;
                    for (var j:int = 0, k:int = array.length; j < k; j++) 
                    {
                        if (array[i] == array[j])
                            count ++;
                    }
                    
                    if (count >= edge)
                        result.push(array[i]);
                }
            }
            return result;
        }
        
        public static function sample(array:*, ...properties):Array
        {
            Asserts.isArray(array);
            
            var result:Array = [];
            
            var l:int = array.length
            var k:int = properties.length;
            for (var i:int = 0; i < l; i++) 
            {
                var item:* = array[i];
                var object:Object = { };
                for (var j:int = 0; j < k; j++) 
                {
                    var property:String = properties[j];
                    if (property in item)
                    {
                        if (item[property] is Function)
                            object[property] = item[property].call(item);
                        else
                            object[property] = item[property];
                    }
                    
                    result.push(object);
                }
            }
            
            return result;
        }
        
        public static function sampleP(array:*, ...properties):Array
        {
            Asserts.isArray(array);
            
            var result:Array = [];
            
            var l:int = array.length
            var k:int = properties.length;
            for (var i:int = 0; i < l; i++) 
            {
                var item:* = array[i];
                for (var j:int = 0; j < k; j++) 
                {
                    var property:String = properties[j];
                    if (property in item)
                    {
                        if (item[property] is Function)
                            result.push(item[property].call(item));
                        else
                            result.push(item[property]);
                    }
                }
            }
            
            return result;
        }
        
        public static function inject(array:*, injections:*, repeat:Boolean = true):Array
        {
            Asserts.isArray(array);
            
            if (!isArray(injections))
                injections = [ injections ];
            
            for (var i:int = 0, j:int = 0, l:int = array.length, k:int = injections.length; i < l; i++, j++) 
            {
                var item:* = array[i];
                var injection:* = injections[j];
                for (var name:String in injection) 
                    if (name in item || E.isDynamic(item))
                        item[name] = injection[name];
                        
                if (j == k - 1)
                {
                    if (repeat)
                        j = -1;
                    else
                        break;
                }
            }
            
            return array;
        }
        
        public static function injectP(array:*, field:String, injections:Array):Array
        {
            Asserts.isArray(array, injections);
            
            for (var i:int = 0, l:int = array.length, k:int = injections.length; i < l && i < k; i++) 
            {
                var item:* = array[i];
                if (field in item)
                    item[field] = injections[i];
            }
            
            return array;
        }
        
        public static function multiply(array:*, times:uint):*
        {
            Asserts.isArray(array);
            
            var i:int;
            var l:int = array.length;
            while (--times)
            {
                for (i = 0; i < l; i++) 
                    array.push(array[i]);
            }
            
            return array;
        }
        
        public static function call(array:*, ...args):Array
        {
            Asserts.isArray(array);
            
            var result:Array = [];
            
            for (var i:int = 0, l:int = array.length; i < l; i++) 
            {
                var item:* = array[i];
                if (item is Function)
                    result.push(item.apply(item, args));
            }
            
            return result;
        }
        
    //--------------------------------------------------------------------------
    //
    //    Instance  
    //
    //--------------------------------------------------------------------------
        private var _items:*;
        private var _data:*
        
        public function EArray(array:* = null) 
        {
            if (array)
            {
                if (EArray.isArray(array))
                {
                    _items = array.slice();
                }
                else if (array is DisplayObjectContainer)
                {
                    _items = [];
                    
                    var parent        :DisplayObjectContainer = array;
                    var length        :int = parent.numChildren;
                    var child        :DisplayObject;
                    var i            :int;
                    
                    for (i = 0; i < length; i++)     // parsing DisplayObjects tree into vector;
                    {
                        child = parent.getChildAt(i);
                        
                        _items.push(child);
                        
                        if (child is DisplayObjectContainer && DisplayObjectContainer(child).numChildren > 0)
                        {
                            parent = child as DisplayObjectContainer;
                            length = parent.numChildren;
                            i = -1;
                            continue;
                        }
                        
                        while (parent != array && i == parent.numChildren - 1)
                        {
                            child = parent;
                            parent = child.parent;
                            length = parent.numChildren;
                            i = parent.getChildIndex(child);
                        }
                    }
                }
                else if (array is Dictionary || E.isSimpleObject(array))
                {
                    _items = [];
                    for (var name:String in array) 
                        _items.push(name, array[name]);
                }
            }
            else
            {
                _items = [];
            }
        }
        
    //----------------------------------
    //  Proxy implementation
    //----------------------------------
        override flash_proxy function callProperty(name:*, ... rest):*
        {
            var field:String = name is QName ? name.localName : String(name); 
            
            if (EString.isDec(field))
            {
                return _items[field]();
            }
            else
            {
                var result:Array = [ ];
                for (var i:int = 0, l:int = _items.length; i < l; i++) 
                {
                    var item:* = _items[i];
                    if (field in item && item[field] is Function)
                        result[i] = item[field].apply(item, rest);
                }
                return new EArray(result);
            }
        }
        
        override flash_proxy function hasProperty(name:*):Boolean 
        {
            var field:String = name is QName ? name.localName : String(name); 
            
            if (EString.isDec(field))
            {
                return field in _items;
            }
            else
            {
                var result:int = 0;
                for (var i:int = 0, l:int = _items.length; i < l; i++) 
                    result += field in _items[i] ? 1 : 0;
                return result == _items.length;
            }
        }
        
        override flash_proxy function getProperty(name:*):*
        {
            var field:String = name is QName ? name.localName : String(name); 
            
            if (EString.isDec(field))
            {
                return _items[field]
            }    
            else
            {
                var result:Array = [ ];
                for (var i:int = 0, l:int = _items.length; i < l; i++) 
                {
                    var item:* = _items[i];
                    if (field in item)
                        result[i] = item[field];
                }
                return new EArray(result);
            }
        }
        
        override flash_proxy function setProperty(name:*, value:*):void 
        {
            var field:String = name is QName ? name.localName : String(name); 
            
            if (EString.isDec(field))
            {
                _items[field] = value;
            }
            else
            {
                for (var i:int = 0, l:int = _items.length; i < l; i++) 
                {
                    try { _items[i][field] = value; }
                    catch (e:Error) { }
                }
            }
        }
        
        override flash_proxy function deleteProperty(name:*):Boolean
        {
            var field:String = name is QName ? name.localName : String(name); 
            
            if (EString.isDec(field))
            {
                return delete _items[name];
            }
            else
            {
                var result:int = 0;
                for (var i:int = 0, l:int = _items.length; i < l; i++)
                {
                    var item:* = _items[i];
                    if (field in item)
                    {
                        try 
                        {
                            delete item[field];
                        }
                        catch (e:Error)
                        {
                            result++;
                        }
                    }
                }
                return result == 0;
            }
        }
        
        override flash_proxy function getDescendants(name:*):* 
        {
            return this.select(name);
        }
        
        override flash_proxy function isAttribute(name:*):Boolean 
        {
            return false;
        }
        
        override flash_proxy function nextName(index:int):String 
        {
            return String(index - 1);
        }
        
        override flash_proxy function nextNameIndex(index:int):int 
        {
            return index < _items.length ? index + 1 : 0;
        }
        
        override flash_proxy function nextValue(index:int):* 
        {
            return _items[index - 1];
        }
        
    //----------------------------------
    //  Array implementation
    //----------------------------------
        /**
         * Adds one or more items to the end of an EArray and returns the new 
         * length of the EArray.
         * 
         * @param args  One or more values to append to the EArray.
         * 
         * @return An integer representing the length of the new EArray.
         */
        public function push(...rest):uint 
        {
            return _items.push.apply(null, [].concat(rest));
        }
        
        /**
         * Removes the last item from an EArray and returns the value of that 
         * item.
         * 
         * @return The value of the last item (of any data type) in the 
         * specified EArray.
         */
        public function pop():* 
        {
            return _items.pop();
        }
        
        /**
         * Adds one or more items to the beginning of an EArray and returns the 
         * new length of the EArray. The other items in the EArray are moved 
         * from their original position, i, to i+1.

         * @param rest  One or more numbers, items, or variables to be inserted 
         * at the beginning of the EArray.
         * 
         * @return An integer representing the new length of the EArray.
         */
        public function unshift(...rest):uint 
        {
            return _items.unshift.apply(null, [].concat(rest));
        }
        
        /**
         * Removes the first item from an EArray and returns that item. The 
         * remaining array items are moved from their original position, i, 
         * to i-1.
         * 
         * @return The first item (of any data type) in an EArray.
         */
        public function shift():* 
        {
            return _items.shift();
        }
        
        /**
         * Concatenates the items specified in the parameters with the items in 
         * an EArray and creates a new EArray. If the parameters specify an 
         * array like object, the items of that object are concatenated. If you 
         * don't pass any parameters, the new EArray is a duplicate (shallow 
         * clone) of the original EArray.
         * 
         * @param rest  A value of any data type (such as numbers, items, or 
         * strings) to be concatenated in a new array.
         * 
         * @return An EArray that contains the items from this array followed by 
         * items from the parameters.
         */
        public function concat(...rest):EArray
        {
            return new EArray(_items.concat.apply(null, [].concat(rest)));
        }
        
        /**
         * Returns a new EArray that consists of a range of items from the 
         * original EArray, without modifying the original array. The returned 
         * EArray includes the startIndex item and all items up to, but not 
         * including, the endIndex item.
         * 
         * If you don't pass any parameters, the new EArray is a duplicate 
         * (shallow clone) of the original array.
         * 
         * @param startIndex    A number specifying the index of the starting 
         * point for the slice. If startIndex is a negative number, the starting  
         * point begins at the end of the EArray, where -1 is the last item.
         * @param endIndex  A number specifying the index of the ending point 
         * for the slice. If you omit this parameter, the slice includes all 
         * items from the starting point to the end of the EArray. If endIndex 
         * is a negative number, the ending point is specified from the end of 
         * the EArray, where -1 is the last item.
         * 
         * @return An array that consists of a range of items from the  original 
         * EArray.
         */
        public function slice(A:* = 0, B:* = 4294967295):EArray 
        {
            return new EArray(_items.slice(A, B));
        }
        
        /**
         * Adds items to and removes items from an EArray. This method modifies 
         * the EArray without making a copy.
         * 
         * Note: To override this method in a subclass of EArray, use ...args 
         * for the parameters, as this example shows:
         * public override function splice(...args) 
         * {
         *         // your statements here
         * }
         * @param startIndex    An integer that specifies the index of the item 
         * in the EArray where the insertion or deletion begins. You can use a 
         * negative integer to specify a position relative to the end of the 
         * EArray (for example, -1 is the last item of the array).
         * @param deleteCount    An integer that specifies the number of items 
         * to be deleted. This number includes the item specified in the 
         * startIndex parameter. If you do not specify a value for the 
         * deleteCount parameter, the method deletes all of the values from the 
         * startIndex item to the last item in the array. If the value is 0, no 
         * items are deleted.
         * @param values    An optional list of one or more comma-separated 
         * values to insert into the EArray at the position specified in the 
         * startIndex parameter. If an inserted value is of type EArray, the 
         * array is kept intact and inserted as a single item. For example,
         * if you splice an existing EArray of length three with another EArray 
         * of length three, the resulting array will have only four items. 
         * One of the items, however, will be an EArray of length three.
         * 
         * @return    An EArray containing the items that were removed from the 
         * original EArray.
         */
        public function splice(startIndex:int, deleteCount:uint, ...values):EArray 
        {
            values.unshift(startIndex, deleteCount);
            return new EArray(_items.splice.apply(null, values));
        }
        
        /**
         * Searches for an item in an EArray by using strict equality (===) and 
         * returns the index position of the item.
         * 
         * @param searchitem  The item to find in the EArray.
         * @param fromIndex   The location in the EArray from which to start 
         * searching for the item.
         * 
         * @return    A zero-based index position of the item in the EArray. If 
         * the searchitem argument is not found, the return value is -1.
         */
        public function indexOf(searchitem:*, fromIndex:* = 0):int 
        {
            return _items.indexOf(searchitem, fromIndex);
        }
        
        /**
         * Searches for an item in an EArray, working backward from the last 
         * item, and returns the index position of the matching item using 
         * strict equality (===).
         * 
         * @param searchitem The item to find in the EArray.
         * @param fromIndex  The location in the EArray from which to start 
         * searching for the item. The default is the maximum value allowed for 
         * an index. If you do not specify fromIndex, the search starts at the 
         * last item in the EArray.
         * 
         * @return    A zero-based index position of the item in the EArray. If 
         * the searchitem argument is not found, the return value is -1.
         */
        public function lastIndexOf(searchitem:*, fromIndex:* = int.MAX_VALUE):int 
        {
            return _items.lastIndexOf(searchitem, fromIndex);
        }
        
        /**
         * Reverses the EArray in place.
         * 
         * @return The new EArray.
         */
        public function reverse():EArray
        {
            return new EArray(_items.reverse());
        }
        
    //----------------------------------
    //  EArray implementation
    //----------------------------------
        /**
         * 
         * @param array
         * @param field
         * @param reverse
         * @return
         */
        public function sort(field:String = null, reverse:Boolean = false):*
        {
            return Sortings.insertion(_items, field, reverse);
        }
        
        /**
         * Searches the EArray for specified value or property and value.
         * 
         * @param value      Desired value.
         * @param property   Desired property.
         * @param indices    If true, indices will be returned, items otherwise.
         * 
         * @return Return depends on returnIndices flag. If true, index will be 
         * returned, item otherwise.
         */
        public function search(value:*, property:String = null, indices:Boolean = false):EArray
        {
            return new EArray(EArray.search(_items, value, property, indices));
        }
        
        /**
         * 
         * @param selector
         * @param inverse
         * @return
         */
        public function indices(selector:*, inverse:Boolean = false):EArray
        {
            return new EArray(EArray.indices(_items, selector, inverse));
        }
        
        public function has(selector:*, inverse:Boolean = false):Boolean
        {
            return EArray.has(_items, selector, inverse);
        }
        
        public function count(selector:*, inverse:Boolean = false):uint
        {
            return EArray.count(_items, selector, inverse);
        }
        
        /**
         * 
         * @param selectors
         * @param inverse
         * @return
         */
        public function select(selector:*):EArray
        {
            return new EArray(EArray.select(_items, selector, false));
        }
        
        public function replace(selector:*, ...items):EArray
        {
            items.unshift(_items, selector);
            EArray.replace.apply(null, items);
            return this;
        }
        
        public function not(selector:*):EArray
        {
            return new EArray(EArray.select(_items, selector, true));
        }
        
        public function filter(selector:*, inverse:Boolean = false):EArray
        {
            EArray.filter(_items, selector, inverse);
            return this;
        }
        
        public function cut(selector:*, inverse:Boolean = false):EArray
        {
            return new EArray(EArray.cut(_items, selector, inverse));
        }
        
        public function first(selector:*, inverse:Boolean = false):*
        {
            var result:* = EArray.select(_items, selector, inverse)
            return result.length ? result[0] : null;
        }
        
        public function last(selector:*, inverse:Boolean = false):*
        {
            var result:* = EArray.select(_items, selector, inverse)
            return result.length ? result[result.length - 1] : null;
        }
        
        public function index(item:*):int
        {
            return _items.indexOf(item);
        }
        
        public function get(index:int = 0):*
        {
            if (index < 0 && _items.length + index > 0)
                return _items[_items.length + index]
            else if (index >= 0 && _items.length > index)
                return _items[index];
        }
        
        public function put(item:*, index:int = int.MAX_VALUE):EArray
        {
            if (index < 0 && _items.length + index > 0)
                _items[_items.length + index] = item;
            else if (index >= 0 && _items.length > index)
                _items[index] = item;
            else
                index < 0 ? _items.unshift(item) : _items.push(item);
            
            return this;
        }
        
        public function each(f:Function, ...args):EArray
        {
            args.unshift(_items, f);
            EArray.each.apply(null, args);
            return this;
        }
        
        public function map(f:Function, ...args):EArray
        {
            args.unshift(_items, f);
            return new EArray(EArray.map.apply(null, args));
        }
        
        public function zip(field:String, value:*):EArray 
        {
            EArray.zip(_items, field, value);
            return this;
        }
        
        public function wrap(wrapper:Class, silent:Boolean = true):EArray
        {
            _items = EArray.wrap(_items, wrapper, silent);
            return this;
        }
        
        public function cast(caster:Class, silent:Boolean = true):EArray
        {
            _items = EArray.cast(_items, caster, silent);
            return this;
        }
        
        public function object(field:String):Object
        {
            return EArray.object(_items, field);
        }
        
        public function dictionary(field:String = null):Dictionary
        {
            return EArray.dictionary(_items, field);
        }
        
        public function unique():EArray
        {
            return new EArray(EArray.unique(_items));
        }
        
        public function sample(...properties):EArray
        {
            properties.unshift(_items);
            return new EArray(EArray.sample.apply(null, properties));
        }
        
        public function sampleP(...properties):EArray
        {
            properties.unshift(_items);
            return new EArray(EArray.sampleP.apply(null, properties));
        }
        
        public function inject(injections:*, repeat:Boolean = true):EArray
        {
            EArray.inject(_items, injections, repeat);
            return this;
        }
        
        public function injectP(field:String, injections:Array):EArray
        {
            EArray.injectP(_items, field, injections);
            return this;
        }
        
        /**
         * The method returns a new EArray containing all the items that are in 
         * either EArray and array.
         * 
         * @param array    Array like instance.
         * @param strict   Indicates whether strict(===) camparing will be used.
         * 
         * @return   Returns a new EArray containing all the items that are in 
         * either list.
         */
        public function union(array:*, strict:Boolean = false):EArray
        {
            return new EArray(EArray.union(_items, array, strict));
        }
    
        /**
         * The method compares items in both EArray and array against each other 
         * and if they match pushes to result EArray.
         * 
         * @param array    Array like instance.
         * @param strict   Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns an EArray with items that enlisted in both lists.
         */
        public function intersection(array:*, strict:Boolean = false):EArray
        {
            return new EArray(EArray.intersection(_items, array, strict));
        }
        
        /**
         * The method returns a new EArray containing all the items that are in 
         * array but not in the EArray.
         * 
         * @param array    Array like instance.
         * @param strict   Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns a new list containing all the items that 
         * are in array but not in the EArray.
         */
        public function difference(array:*, strict:Boolean = false):EArray
        {
            return new EArray(EArray.difference(_items, array, strict));
        }
        
        /**
         * The method returns a new EArray containing all the items that are in 
         * exactly one of the lists.
         * 
         * @param array    Array like instance.
         * @param strict   Indicates whether strict(===) camparing will be used.
         * 
         * @return Returns a new EArray containing all the items that are in
         * exactly one of the listss.
         */
        public function symmetricDifference(array:*, strict:Boolean = false):EArray
        {
            return new EArray(EArray.symmetricDifference(_items, array, strict));
        }
        
        /**
         * Generates new list basing on the argument string representation, if 
         * argument is an array like instance, its items will be used instead, 
         * concatenated to the EArray items' string representations, resulting 
         * in EArray of NxM items.
         * 
         * @param any   Any type value.
         * 
         * @return  Returns new EArray based on the argument array's items.
         */
        public function conjunction(any:*):EArray
        {
            return new EArray(EArray.conjunction(_items, any));
        }
        
        /**
         * Multiplies EArray items N times, if items are objects, references
         * will be copied, not objects itself.
         * 
         * @param times multiplier
         * @return Returns self.
         */
        public function multiply(times:uint):EArray
        {
            EArray.multiply(_items, times);
            return this;
        }
        
        public function isSubset(array:*, strict:Boolean = false):Boolean
        {
            return EArray.isSubset(array, _items, strict);
        }
        
        public function clear():EArray
        {
            while (_items.length)
                _items.pop();
            return this;
        }
    
    //----------------------------------
    //  Common
    //----------------------------------
        /**
         * The method returns string representation of all items of EArray 
         * separated by comma.
         * 
         * @return String value of EArray.
         */
        public function toString():String
        {
            return _items.toString()
        }
        
    //--------------------------------------------------------------------------
    //
    //  Accessors
    //
    //--------------------------------------------------------------------------
        
        /**
         * Original array object.
         */
        public function get items():* 
        { 
            return _items; 
        }
        
        public function set items(value:*):void 
        { 
            Asserts.isArray(value);
            _items = value; 
        }
        
        public function get data():* 
        { 
            return _data; 
        }
        
        public function set data(value:*):void 
        { 
            _data = value; 
        }
        
        /**
         * A non-negative integer specifying the number of items in the array. 
         * This property is automatically updated when new items are added to 
         * the array. When you assign a value to an array item (for example, 
         * my_array[index] = value), if index is a number, and index+1 is 
         * greater than the length property, the length property is updated to 
         * index+1. 
         * 
         * Note: If you assign a value to the length property that is shorter 
         * than the existing length, the array will be truncated.
         */
        public function get length():uint 
        { 
            return _items.length; 
        }
        
        public function set length(value:uint):void 
        { 
            _items.length = value; 
        }
    }
}