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
    import flash.events.TimerEvent;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    
    /**
     * @author Artyom Goncharov 11.06.2011 16:06
     * 
     * SORTINGS TEST DRIVE | Intel(R) Core(TM) i5-3570K 3.40GHz, Windows Seven x64, time: 84586
     * -------------------------------------------------------------------------------------------------------------------------------------------------------------------
     *    10     100    1000    5000    10000    15000    20000    25000    30000    35000    40000    45000    50000    100000    150000    200000    500000    1000000
     * -------------------------------------------------------------------------------------------------------------------------------------------------------------------
     *     0       1     106    2502     9908        -        -        -        -        -        -        -        -        -        -        -        -        -    bubble
     *     1       0      78    1511     6033        -        -        -        -        -        -        -        -        -        -        -        -        -    coctail
     *     1       0      84    1698     6735        -        -        -        -        -        -        -        -        -        -        -        -        -    gnome
     *     0       0      28     487     1975     4386     7910        -        -        -        -        -        -        -        -        -        -        -    insertion
     *     1       0       8      93      349      745     1350     2098     2965     4111     5454        -        -        -        -        -        -        -    radixBucket
     *     0       0       9      36       68       83      115      145      173      212      243      272      304      634      993     1318     3462     7235    radixBucketExt
     *     0       0       1       8       18       13       16       19       23       28       32       54       40       79      121      160      409      841    counting
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------
     * 
     * N.B. All test'd been perform on lists of uniformly distributed 
     * pseudo-random numbers;). Some sortings are meant to be used under other 
     * circumstances; counting sort could be much faster if pseudo-random number 
     * range smaller than lists length(range 0..1000 and number 1kk, for 
     * example). Time limit 5000ms.
     */
    public final class Sortings
    {
        public static function test(callback:Function):void
        {
            var stage:int = 0;
            var stages:Array = 
            [
                    10,     100,    1000,    5000, 
                 10000,   15000,   20000,   25000, 
                 30000,   35000,   40000,   45000, 
                 50000,  100000,  150000,  200000,
                500000, 1000000
            ];
            var values:Array;
            var sorting:int = 0;
            var sortings:Array = 
            [
                { name: 'bubble',          sort: bubble,         results: [] },
                { name: 'coctail',         sort: coctail,        results: [] },
                { name: 'gnome',           sort: gnome,          results: [] },
                { name: 'insertion',       sort: insertion,      results: [] },
                { name: 'radixBucket',     sort: radixBucket,    results: [] },
                { name: 'radixBucketExt',  sort: radixBucketExt, results: [] },
                { name: 'counting',        sort: counting,       results: [] }
            ];
            var current:Object;
            var local:int;
            var total:int = getTimer();
            var timer:Timer;
            var i:int;
            var j:int;

            timer = new Timer(1000/30);
            timer.addEventListener(TimerEvent.TIMER, function():void
            {
                timer.stop();
                
                if (stage == 0)
                {
                    current = sortings[sorting];
                    values = [];
                    for (i = 0; i < stages.length; i++) 
                    {
                        values.push([]);
                        for (j = 0; j < stages[i]; j++) 
                            values[i].push(Math.round(Math.random() * (Math.random() * stages[i])));
                    }
                }
                
                if (local < 5000 && stage < stages.length)
                {
                    local = getTimer();
                    current.sort(values[stage]);
                    local = getTimer() - local;
                    current.results.push(local);
                    stage++;
                }
                else
                {
                    local = 0;
                    stage = 0;
                    sorting++;
                }
                
                if (sorting < sortings.length)
                {
                    timer.reset();
                    timer.start();
                }
                else
                {
                    var 
                    echo:String = '\nSORTINGS TEST DRIVE | time: ' + (getTimer() - total);
                    echo += '\n{0}\n';
                    
                    for (i = 0; i < stages.length; i++) 
                        echo += '\t' + stages[i];
                    echo += '\n{0}';
                    
                    for (i = 0; i < sortings.length; i++) 
                    {
                        echo += '\n';
                        for (j = 0; j < stages.length; j++) 
                            echo += '\t' + (sortings[i].results[j] == undefined ? '-' : sortings[i].results[j]);
                        echo += '\t' + sortings[i].name;
                    }
                    echo += '\n{0}\n';
                    
                    callback(
                    { 
                        results: sortings, 
                         stages: stages, 
                           echo: EString.format(echo, EString.multiply('-', 140)) 
                    });
                }
            });
            timer.start();
        }
        
        public static function bubble(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var flag  :Boolean;
            var temp  :*;
            var i     :int;
            var l     :int;
            
            if (field && field != '')
            {
                while (!flag)
                {
                    flag = true;
                    for (i = 0, l = array.length - 1; i < l; i++) 
                    {
                        if (array[i][field] > array[i + 1][field])
                        {
                            temp = array[i];
                            array[i] = array[i + 1];
                            array[i + 1] = temp;
                            flag = false;
                        }
                    }
                }
            }
            else
            {
                while (!flag)
                {
                    flag = true;
                    for (i = 0, l = array.length - 1; i < l; i++) 
                    {
                        if ((array[i] > array[i + 1]))
                        {
                            temp = array[i];
                            array[i] = array[i + 1];
                            array[i + 1] = temp;
                            flag = false;
                        }
                    }
                }
            }
            
            reverse && array.reverse();
                
            return array;
        }
        
        public static function coctail(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var left    :int = 0;
            var right   :int = array.length - 1;
            var temp    :*;
            var i       :int;
            
            if (field && field != '')
            {
                while (left < right)
                {
                    for (i = left; i < right; i++) 
                    {
                        if ((array[i][field] > array[i + 1][field]))
                        {
                            temp = array[i];
                            array[i] = array[i + 1];
                            array[i + 1] = temp;
                        }
                    }
                    right--;
                    
                    for (i = right; i > left; i--) 
                    {
                        if ((array[i][field] < array[i - 1][field]))
                        {
                            temp = array[i];
                            array[i] = array[i - 1];
                            array[i - 1] = temp;
                        }
                    }
                    left++;
                }
            }
            else
            {
                while (left < right)
                {
                    for (i = left; i < right; i++) 
                    {
                        if ((array[i] > array[i + 1]))
                        {
                            temp = array[i];
                            array[i] = array[i + 1];
                            array[i + 1] = temp;
                        }
                    }
                    right--;
                    
                    for (i = right; i > left; i--) 
                    {
                        if ((array[i] < array[i - 1]))
                        {
                            temp = array[i];
                            array[i] = array[i - 1];
                            array[i - 1] = temp;
                        }
                    }
                    left++;
                }
            }
            
            reverse && array.reverse();
            
            return array;
        }
        
        public static function gnome(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var left    :int = 1;
            var right   :int = 2;
            var temp    :int;
            
            if (field && field != '')
            {
                while (left < array.length)
                {
                    if (array[left - 1][field] <= array[left][field])
                    {
                        left = right;
                        right++;
                    }
                    else
                    {
                        temp = array[left];
                        array[left] = array[left - 1];
                        array[left - 1] = temp;
                        left--;
                        if (left == 0)
                        {
                            left = right;
                            right++;
                        }
                    }
                }
            }
            else
            {
                while (left < array.length)
                {
                    if (array[left - 1] <= array[left])
                    {
                        left = right;
                        right++;
                    }
                    else
                    {
                        temp = array[left];
                        array[left] = array[left - 1];
                        array[left - 1] = temp;
                        left--;
                        if (left == 0)
                        {
                            left = right;
                            right++;
                        }
                    }
                }
            }
            
            reverse && array.reverse();
        }
        
        public static function insertion(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var temp :*;
            var i    :int;
            var j    :int;
            var l    :int
            
            if (field && field != '')
            {
                for (i = 1, l = array.length; i < l; i++) 
                {
                    temp = array[i];
                    
                    for (j = i - 1; (j >= 0) && (array[j][field] > temp[field]); j--)
                        array[j + 1] = array[j];
                    
                    array[j + 1] = temp;
                }
            }
            else
            {
                for (i = 1, l = array.length; i < l; i++) 
                {
                    temp = array[i];
                    
                    for (j = i - 1; (j >= 0) && (array[j] > temp); j--)
                        array[j + 1] = array[j];
                    
                    array[j + 1] = temp;
                }
            }
            
            reverse && array.reverse();
            
            return array;
        }
        
        public static function radixBucket(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var buckets :Array = [];
            var bit     :int;
            var item    :*;
            var i       :int;
            var j       :int;
            
            // searching for the biggest key
            for (i = 0; i < array.length; i++) 
                if (array[i] > bit)
                    bit = array[i];
            
            // searching for the higgest bit        
            for (i = 31; i >= 0; i--) 
                if (((bit >> i) & 0x01) == 1)
                {
                    bit = i;
                    break;
                }
                
            // creating bit + 1 buckets
            while (buckets.length != bit + 1) 
                buckets.push([]);
                
            // buckets filling
            while (array.length)
            {
                item = array.pop();
                if (item == 0)
                    buckets[0].push(item);
                    
                for (j = bit; j >= 0; j--) 
                {
                    if (((item >> j) & 0x01) == 1)
                    {
                        buckets[j].push(item);
                        break;
                    }
                }
            }
            // concatenation
            for (i = 0; i < buckets.length; i++) 
            {
                insertion(buckets[i], null);
                while (buckets[i].length)
                    array.push(buckets[i].shift());
            }
            
            reverse && array.reverse();
            
            return array;
        }
        
        public static function radixBucketExt(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var biggers     :Array;
            var lessers     :Array;
            var holder      :Array = [ array.slice() ];
            var quant       :Array;
            var item        :*;
            var buckets     :Array;
            var shift       :int;
            var i           :int;
            
            // searching for the biggest key
            for (i = 0; i < array.length; i++) 
                if (array[i] > shift)
                    shift = array[i];
            
            // searching for the higgest bit        
            for (i = 31; i >= 0; i--) 
                if (((shift >> i) & 0x01) == 1)
                {
                    shift = i;
                    break;
                }
                
            // list quanting    
            while (shift > 5)
            {
                buckets = [];
                
                while (holder.length)
                {
                    biggers = [];
                    lessers = [];
                    quant = holder.shift();
                    
                    if (quant.length == 0)
                        continue;
                        
                    if (quant.length < 100)
                    {
                        buckets.push(quant);
                        continue;
                    }
                    else
                    {
                        while (quant.length)
                        {
                            item = quant.pop();
                            if (((item >> shift) & 0x01) == 1)
                                biggers.push(item);
                            else
                                lessers.push(item);
                        }
                        buckets.push(lessers, biggers);
                    }
                }
                
                holder = buckets;
                shift--;
            }
            
            // concatenation
            array.length = 0;
            for (i = 0; i < holder.length; i++) 
            {
                insertion(holder[i], null);
                while (holder[i].length)
                    array.push(holder[i].shift());
            }
            
            reverse && array.reverse();
            
            return array;
        }
        
        private static function radix(list:Object, shift:int):Array
        {
            var biggers   :Array = [];
            var lessers   :Array = [];
            var result    :Array = [];
            var temp      :Array = [];
            
            while (list.length)
            {
                if (((list[0] >> shift) & 0x01) == 1)
                    biggers.push(list.shift());
                else
                    lessers.push(list.shift());
            }
            
            shift--;
            
            if (shift >= 0)
            {
                result = radix(lessers, shift);
                temp = radix(biggers, shift); 
                while (temp.length) 
                    result.push(temp.shift());
            }
            else
            {
                result = [ lessers, biggers];
            }
            
            return result;
        }
        
        public static function counting(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            
            var min      :int = array[0];
            var max      :int = array[0];
            var counts   :Array = [];
            var count    :int;
            var length   :int;
            var i        :int;
            
            for (i = 0; i < array.length; i++) 
            {
                if (array[i] < min)    min = array[i];
                if (array[i] > max)    max = array[i];
            }
            
            length = max - min + 1;
            
            while (counts.length != length) 
                counts.push(0);
            
            while (array.length) 
                counts[array.pop() - min]++;
            
            for (i = 0; i < counts.length; i++) 
            {
                count = counts[i];
                while (count > 0) 
                {
                    array.push(i + min);
                    count--;
                }
            }
            
            reverse && array.reverse();
            
            return array;
        }
        
        public static function merge(array:*, field:String = null, reverse:Boolean = false):*
        {
            Asserts.isArray(array);
            return array;
        }
    }
}