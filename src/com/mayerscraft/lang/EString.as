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
     * @author Artyom Goncharov 07.03.2013 16:33
     */
    public class EString 
    {
    //--------------------------------------------------------------------------
    //
    //  static
    //
    //--------------------------------------------------------------------------
        public static const WHITESPACE:String = ' \t\n\r\x0b\x0c';
        
        /**
         * Checks whether the 'string' is a hex number.
         * 
         * @param  string  String to be checked.
         * @return Returns TRUE if 'string' is a hex number.
         */
        public static function isHex(string:String):Boolean
        {
            return EArray.isSubset(chars('x0123456789abcdef'), chars(string.toLowerCase()));
        }
        
        public static function isDec(string:String):Boolean
        {
            return EArray.isSubset(chars('0123456789'), chars(string.toLowerCase()));
        }
        
        public static function prepend(string:String, slice:String, times:int = 1):String
        {
            if (times >= 0)
                for (var i:int = 0; i < times; i++) 
                    string = slice + string;
            return string;
        }
        
        public static function append(string:String, slice:String, times:int = 1):String
        {
            if (times >= 0)
                for (var i:int = 0; i < times; i++) 
                    string = string + slice;
            return string;
        }
        
        public static function surround(string:String, slice:String, times:int = 1):String
        {
            return append(prepend(string, slice, times), slice, times);
        }
        
        public static function trim(string:String, chars:String = WHITESPACE):String
        {
            if (string && string.length != 0)
            {
                while (string.length != 0 && chars.indexOf(string.slice(0, 1)) != -1)
                    string = string.slice(1);
                    
                while (string.length != 0 && chars.indexOf(string.slice(string.length - 1, string.length)) != -1)
                    string = string.slice(0, string.length - 1);
            }
            
            return rtrim(ltrim(string, chars), chars);
        }
        
        public static function ltrim(string:String, chars:String = WHITESPACE):String
        {
            if (string && string.length != 0)
                while (string.length != 0 && chars.indexOf(string.slice(0, 1)) != -1)
                    string = string.slice(1);
            
            return string;
        }
        
        public static function rtrim(string:String, chars:String = WHITESPACE):String
        {
            if (string && string.length != 0)
                while (string.length != 0 && chars.indexOf(string.slice(string.length - 1, string.length)) != -1)
                    string = string.slice(0, string.length - 1);
            
            return string;
        }
        
        public static function strip(string:String):String
        {
            return trim(string, WHITESPACE);
        }
        
        public static function lstrip(string:String):String
        {
            return ltrim(string, WHITESPACE);
        }
        
        public static function rstrip(string:String):String
        {
            return rtrim(string, WHITESPACE);
        }
        
        public static function chars(string:String):Array
        {
            return string.split('');
        }
        
        /**
         * Fills and returns template with specified values. Template is a 
         * string with value fields specifield like {N}, where N is the passed 
         * value index.
         * 
         * @param template    Template string.
         * @param ...values   Values.
         * 
         * @return Returns new String filled with specified values.
         */
        public static function format(template:String, ...values):String
        {
            var result:String = template.substr();
            for (var key:* in values) 
                result = result.replace(new RegExp('{\s*' + String(key) + '\s*}', 'g'), String(values[key]));
            
            return result;
        }
        
        public static function multiply(string:String, times:int):String
        {
            var s:String = string;
            while (times--)
                string = string + s;
            return string
        }
        
        public static function formatCommaThousands(number:Number, numbersAfterDot:uint = 0):String
        {
            return number.toFixed(numbersAfterDot).replace( /\d{1,3}(?=(\d{3})+(?!\d))/g , "$&,");
        }
        
        /**
         * Creates new String describes 'object' with specified parameters.
         * The method can use fields and methods of 'object';
         * 
         * @param object    Object to be described.
         * @param name      Name of the object.
         * @param ...fields Fields to be included in the description.
         * 
         * @return Creates new String describes 'object' with specified 
         * parameters.
         */
        public static function toString(object:Object, name:String, ...fields):String
        {
            if (object)
            {
                var result:String = '[' + name;
                for (var i:int = 0; i < fields.length; i++) 
                {
                    var field:String = fields[i];
                    if (field.indexOf('()') == field.length - 2)
                    {
                        var method:String = field.substring(0, field.length - 2);
                        if (method in object)
                        {
                            try 
                            {
                                result += ' ' + method + ': ' + String(object[method].call());
                            }
                            catch (e:Error)
                            {
                                result += ' ' + field;
                            }
                        }
                        else
                        {
                            result += ' ' + field;
                        }
                    }
                    else
                    {
                        result += ' ' + field;
                        if (field in object)
                            result += ': ' + String(object[field]);
                            
                    }
                }
                
                return result + ']';
            }
            else
            {
                return 'NULL[' + name + ']';
            }
        }
        
    //--------------------------------------------------------------------------
    //
    //  instance
    //
    //--------------------------------------------------------------------------
        private var _string:String
        
        public function EString(string:String) 
        {
            _string = string;
        }
        
    //----------------------------------
    //  String implementation
    //----------------------------------
        /**
         * Returns the character in the position specified by the index
         * parameter. If index is not a number from 0 to string.length - 1, an 
         * empty string is returned.
         * 
         * This method is similar to String.charCodeAt() except that the 
         * returned value is a character, not a 16-bit integer character code.
         * 
         * @param index An integer specifying the position of a character in 
         * the string. The first character is indicated by 0, and the last 
         * character is indicated by my_str.length - 1.
         * 
         * @return The character at the specified index. Or an empty string if 
         * the specified index is outside the range of this string's indices.
         */
        public function charAt(i:Number = 0):String 
        {
            return _string.charAt(i);
        }
        
        /**
         * Returns the numeric Unicode character code of the character at the 
         * specified index. If index is not a number from 0 to string.length - 1, 
         * NaN is returned.
         * 
         * This method is similar to String.charAt() except that the returned 
         * value is a 16-bit integer character code, not the actual character.
         * 
         * @param index An integer that specifies the position of a character 
         * in the string. The first character is indicated by 0, and the last 
         * character is indicated by my_str.length - 1.
         * 
         * @return The Unicode character code of the character at the specified 
         * index. Or NaN if the index is outside the range of this string's 
         * indices. Unicode values are defined in the Unicode Character Database 
         * specification.
         */
        public function charCodeAt(i:Number = 0):Number 
        {
            return _string.charCodeAt(i);
        }
        
        /**
         * Appends the supplied arguments to the end of the String object, 
         * converting them to strings if necessary, and returns the resulting 
         * string. The original value of the source String object remains 
         * unchanged.
         * 
         * @param args  Zero or more values to be concatenated.
         * 
         * @return A new string consisting of this string concatenated with the 
         * specified parameters.
         */
        public function concat(...rest):String 
        {
            return _string.concat.apply(null, [].concat(rest));
        }
        
        /**
         * Searches the string and returns the position of the first occurrence 
         * of val found at or after startIndex within the calling string. This 
         * index is zero-based, meaning that the first character in a string is 
         * considered to be at index 0--not index 1. If val is not found, the 
         * method returns -1.
         * 
         * @param val           The substring for which to search.
         * @param startIndex    An optional integer specifying the starting 
         * index of the search.
         * 
         * @return The index of the first occurrence of the specified substring 
         * or -1.
         */
        public function indexOf(s:String = undefined, i:Number = 0):int 
        {
            return _string.indexOf(s, i);
        }
        
        /**
         * Searches the string from right to left and returns the index of the 
         * last occurrence of val found before startIndex. The index is 
         * zero-based, meaning that the first character is at index 0, and the 
         * last is at string.length - 1. If val is not found, the method 
         * returns -1.
         * 
         * @param val           The string for which to search.
         * @param startIndex    An optional integer specifying the starting index 
         * from which to search for val. The default is the maximum value allowed 
         * for an index. If startIndex is not specified, the search starts at the 
         * last item in the string.
         * 
         * @return The position of the last occurrence of the specified substring or -1 
         * if not found.
         */
        public function lastIndexOf(s:String = undefined, i:Number = 2147483647):int 
        {
            return _string.lastIndexOf(s, i);
        }
        
        /**
         * Compares the sort order of two or more strings and returns the result 
         * of the comparison as an integer. While this method is intended to 
         * handle the comparison in a locale-specific way, the ActionScript 3.0 
         * implementation does not produce a different result from other string 
         * comparisons such as the equality (==) or inequality (!=) operators.
         * 
         * If the strings are equivalent, the return value is 0.
         * 
         * If the original string value precedes the string value specified by 
         * other, the return value is a negative integer, the absolute value of 
         * which represents the number of characters that separates the two 
         * string values. 
         * 
         * If the original string value comes after other, the return value is a 
         * positive integer, the absolute value of which represents the number 
         * of characters that separates the two string values.
         * 
         * @param other    A string value to compare.
         * @param values   Optional set of more strings to compare.
         * 
         * @return The value 0 if the strings are equal. Otherwise, a negative 
         * integer if the original string precedes the string argument and a 
         * positive integer if the string argument precedes the original string. 
         * In both cases the absolute value of the number represents the 
         * difference between the two strings.
         */
        public function localeCompare(other:* = null):int 
        {
            return _string.localeCompare(other);
        }
        
        /**
         * Matches the specifed pattern against the string.
         * 
         * @param pattern   The pattern to match, which can be any type of 
         * object, but it is typically either a string or a regular expression. 
         * If the pattern is not a regular expression or a string, then the 
         * method converts it to a string before executing.
         * 
         * @return An array of strings consisting of all substrings in the 
         * string that match the specified pattern.
         *   
         * If pattern is a regular expression, in order to return an array with 
         * more than one matching substring, the g (global) flag must be set in 
         * the regular expression: If the g (global) flag is not set, the return 
         * array will contain no more than one match, and the lastIndex property 
         * of the regular expression remains unchanged.If the g (global) flag is 
         * set, the method starts the search at the beginning of the string 
         * (index position 0). If a matching substring is an empty string (which 
         * can occur with a regular expression such as /x~~/), the method adds 
         * that empty string to the array of matches, and then continues 
         * searching at the next index position.  The lastIndex property of the 
         * regular expression is set to 0 after the method completes. If no 
         * match is found, the method returns an empty array. If you pass no 
         * value (or an undefined value) as the pattern parameter, the method 
         * returns null.
         * 
         * @oldexample    <pre xml:space="preserve" class="- topic/pre "><code>
         *   var myPattern:RegExp = /sh./g;  
         *   // The dot (.) matches any character.
         *   var str:String = "She sells seashells by the seashore.";
         *   trace(str.match(myPattern));
         *   
         *     // Output: she,sho
         *   
         *     myPattern = /sh./gi;  
         *   // This time, make it case insensitive (with the i flag).
         *   str = "She sells seashells by the seashore.";
         *   trace(str.match(myPattern));
         *   
         *     // Output: She,she,sho
         *   
         *     myPattern = RegExp = new RegExp("sh(.)", "gi")  
         *   // Note the grouping parentheses.
         *   str = "She sells seashells by the seashore.";
         *   trace(str.match(myPattern));
         *   
         *     // Output: She,e,she,e,sho,o
         *   // Note that the result array is 
         *   // [[She,e],[she,e],[sho,o]] 
         *   </code></pre>
         */
        public function match(p:* = null):Array 
        {
            return _string.match(p);
        }
        
        /**
         * Matches the specifed pattern against the string and returns a new 
         * string in which the first match of pattern is replaced with the 
         * content specified by repl. The pattern parameter can be a string or 
         * a regular expression. The repl parameter can be a string or a 
         * function; if it is a function, the string returned by the function is 
         * inserted in place of the match. The original string is not modified.
         * 
         * In the following example, only the first instance of "sh" 
         * (case-sensitive) is replaced: 
         * <codeblock>
         * 
         *   var myPattern:RegExp = /sh/;  
         * var str:String = "She sells seashells by the seashore.";
         * trace(str.replace(myPattern, "sch"));  
         * // She sells seaschells by the seashore.
         * </codeblock>
         * In the following example, all instances of "sh" (case-sensitive) are 
         * replaced because the g (global) flag is set in the regular expression: 
         * <codeblock>
         * 
         *   var myPattern:RegExp = /sh/g;  
         * var str:String = "She sells seashells by the seashore.";
         * trace(str.replace(myPattern, "sch"));  
         * // She sells seaschells by the seaschore.
         * </codeblock>
         * In the following example, all instance of "sh" 
         * are replaced because the g (global) flag is set in the regular 
         * expression and the matches are not case-sensitive because the i 
         * (ignoreCase) flag is set:
         * <codeblock>
         * 
         *   var myPattern:RegExp = /sh/gi;  
         * var str:String = "She sells seashells by the seashore.";
         * trace(str.replace(myPattern, "sch"));  
         * // sche sells seaschells by the seaschore.
         * </codeblock>
         * 
         * @param pattern   The pattern to match, which can be any type of 
         * object, but it is typically either a string or a regular expression. 
         * If you specify a pattern parameter that is any object other than a 
         * string or a regular expression, the toString() method is applied to 
         * the parameter and the replace() method executes using the resulting 
         * string as the pattern.
         * @param repl  Typically, the string that is inserted in place of the 
         * matching content. However, you can also specify a function as this 
         * parameter. If you specify a function, the string returned by the 
         * function is inserted in place of the matching content.
         *   
         * When you specify a string as the repl parameter and specify a regular 
         * expression as the pattern parameter, you can use the following special 
         * $ replacement codes in the repl string:$ Code Replacement Text 
         * $$$$&The matched substring. $`The portion of the string that precedes 
         * the matched substring. Note that this code uses the straight left 
         * single quote character (`), not the straight single quote character 
         * (') or the left curly single quote character (). $'The portion of 
         * string that follows the matched substring. Note that this code uses 
         * the straight single quote character ('). $nThe nth captured 
         * parenthetical group match, where n is a single digit 1-9 and $n is 
         * not followed by a decimal digit. $nnThe nnth captured parenthetical 
         * group match, where nn is a two-digit decimal number (01-99). If the 
         * nnth capture is undefined, the replacement text is an empty string. 
         * For example, the following shows the use of the $2 and $1 replacement 
         * codes, which represent the first and second capturing group matched:
         *   <codeblock>
         *      var str     :String = "flip-flop";
         *      var pattern :RegExp = /(\w+)-(\w+)/g;
         * 
         *      trace(str.replace(pattern, "$2-$1")); // flop-flip
         *   </codeblock>
         * 
         *   When you specify a function as the repl, the replace() method
         *   passes the following parameters to the function:
         *   
         *  The matching portion of the string.
         *   
         *     Any captured parenthetical group matches are provided as the next 
         *     arguments. The number of arguments passed this way will vary 
         *     depending on the number of parenthetical matches. You can 
         *     determine the number of parenthetical matches by checking 
         *     arguments.length - 3 within the function code.
         *   
         *  The index position in the string where the match begins.
         *   
         *  The complete string.
         *   For example, consider the following:
         *   <codeblock>
         *      var str1    :String = "abc12 def34";
         *      var pattern :RegExp = /([a-z]+)([0-9]+)/;
         *      var str2    :String = str1.replace(pattern, replFN);
         * 
         *      trace (str2);   // 12abc 34def
         *      
         *      function replFN():String 
         *      {
         *         return arguments[2] + arguments[1];
         *      }
         *   </codeblock>
         *   The call to the replace() method uses a function as the repl 
         *   parameter. The regular expression (/([a-z]([0-9]/g) is matched 
         *   twice. The first time, the pattern matches the substring "abc12", 
         *   and the following list of arguments is passed to the function:
         *   <codeblock>
         *     {"abc12", "abc", "12", 0, "abc12 def34"}
         *   </codeblock>
         * 
         *   The second time, the pattern matches the substring "def23", and the 
         *   following list of arguments is passed to the function:
         *   <codeblock>
         *     {"def34", "def", "34", 6, "abc123 def34"}
         *   </codeblock>
         * 
         * @return The resulting string. Note that the source string remains 
         * unchanged.
         */
        public function replace(p:* = null, repl:* = null):String 
        {
            return _string.replace(p, repl);
        }
        
        /**
         * Searches for the specifed pattern and returns the index of the first 
         * matching substring. If there is no matching substring, the method 
         * returns -1.
         * 
         * @param pattern   The pattern to match, which can be any type of 
         * object but is typically either a string or a regular expression.. If 
         * the pattern is not a regular expression  or a string, then the method 
         * converts it to a string before executing. Note that if you specify a 
         * regular expression, the method ignores the global flag ("g") of the 
         * regular expression, and it ignores the lastIndex property of the 
         * regular expression (and leaves it unmodified). If you pass an 
         * undefined value (or no value), the method returns -1.
         * 
         * @return The index of the first matching substring, or -1 if there is 
         * no match. Note that the string is zero-indexed; the first character 
         * of the string is at index 0, the last is at string.length - 1.
         * 
         * @oldexample    
         * <pre xml:space="preserve" class="- topic/pre ">
         *   <code>
         *     var str:String = "She sells seashells by the seashore.";
         *     var myPattern:RegExp = /sh/;  
         *     // This time, make it case insensitive (with the i flag).
         *     trace(str.match(myPattern));
         *   
         *     // Output: 13
         *     // (The substring match starts at character position 13.)
         *   
         *     var myPattern:RegExp = /sh/i;
         *     trace(str.match(myPattern));
         *   
         *     // Output: 0
         *     // (The substring match starts at character position 0 
         *     //   -- the first character of the source string.)
         *   </code>
         * </pre>
         */
        public function search(p:* = null):int 
        {
            return _string.search(p);
        }
        
        /**
         * Returns a string that includes the startIndex character and all 
         * characters up to, but not including, the endIndex character. The 
         * original String object is not modified. If the endIndex parameter is 
         * not specified, then the end of the substring is the end of the string. 
         * If the character indexed by startIndex is the same as or to the right 
         * of the character indexed by endIndex, the method returns an empty 
         * string.
         * 
         * @param startIndex    The zero-based index of the starting point 
         * for the slice. If startIndex is a negative number, the slice is 
         * created from right-to-left, where -1 is the last character.
         * @param endIndex      An integer that is one greater than the index of 
         * the ending point for the slice. The character indexed by the endIndex 
         * parameter is not included in the extracted string. If endIndex is a 
         * negative number, the ending point is determined by counting back from 
         * the end of the string, where -1 is the last character. The default is 
         * the maximum value allowed for an index. If this parameter is omitted, 
         * String.length is used.
         * 
         * @return A substring based on the specified indices.
         */
        public function slice(start:Number = 0, end:Number = int.MAX_VALUE):String 
        {
            return _string.slice(start, end);
        }
        
        /**
         * Splits a String object into an array of substrings by dividing it 
         * wherever the specified delimiter parameter occurs.
         * 
         * If the delimiter parameter is a regular expression, only the first 
         * match at a given position of the string is considered, even if 
         * backtracking could find a nonempty substring match at that position. 
         * For example:
         * <codeblock>
         *   var str:String = "ab";
         *   var results:Array = str.split(/a~~?/); // results == ["","b"]
         * 
         *   results = str.split(/a~~/); // results == ["","b"].)
         * </codeblock>
         * 
         * If the delimiter parameter is a regular expression containing 
         * grouping parentheses, then each time the delimiter is matched, the 
         * results (including any undefined results) of the grouping parentheses 
         * are spliced into the output array. For example
         * <codeblock>
         *  var str:String = "Thi5 is a tricky-66 example.";
         *  var re:RegExp = /(\d+)/;
         *  var results:Array = str.split(re);
         *  // results == ["Thi","5"," is a tricky-","66"," example."]
         * </codeblock>
         * 
         * If the limit parameter is specified, then the returned array will 
         * have no more than the specified number of elements.If the delimiter 
         * is an empty string, an empty regular expression, or a regular e
         * xpression that can match an empty string, each single character in 
         * the string is output as an element in the array.If the delimiter 
         * parameter is undefined, the entire string is placed into the first 
         * element of the returned array.
         * 
         * @param delimiter The pattern that specifies where to split this 
         * string. This can be any type of object but is typically either a 
         * string or a regular expression. If the delimiter is not a regular 
         * expression or string, then the method converts it to a string before 
         * executing.
         * @param limit     The maximum number of items to place into the 
         * array. The default is the maximum value allowed.
         * @return An array of substrings.
         */
        public function split(delim:* = null, limit:* = int.MAX_VALUE):Array 
        {
            return _string.split(delim, limit);
        }
        
        /**
         * Returns a substring consisting of the characters that start at the 
         * specified startIndex and with a length specified by len. The original 
         * string is unmodified.
         * 
         * @param startIndex    An integer that specified the index of the first 
         * character to be used to create the substring. If startIndex is a 
         * negative number, the starting index is determined from the end of the 
         * string, where -1 is the last character.
         * @param len   The number of characters in the substring being created. 
         * The default value is the maximum value allowed. If len is not 
         * specified, the substring includes all the characters from startIndex 
         * to the end of the string.
         * 
         * @return A substring based on the specified parameters.
         */
        public function substr(start:Number = 0, len:Number = int.MAX_VALUE):String 
        {
            return _string.substr(start, len);
        }
        
        /**
         * Returns a string consisting of the character specified by startIndex 
         * and all characters up to endIndex - 1. If endIndex is not specified, 
         * String.length is used. If the value of startIndex equals the value of 
         * endIndex, the method returns an empty string. If the value of 
         * startIndex is greater than the value of endIndex, the parameters are 
         * automatically swapped before the function executes. The original 
         * string is unmodified.
         * 
         * @param startIndex    An integer specifying the index of the first 
         * character used to create the substring. Valid values for startIndex 
         * are 0 through String.length. If startIndex is a negative value, 0 is 
         * used.
         * @param endIndex  An integer that is one greater than the index of the 
         * last character in the extracted substring. Valid values for endIndex 
         * are 0 through String.length. The character at endIndex is not 
         * included in the substring. The default is the maximum value allowed 
         * for an index. If this parameter is omitted, String.length is used. 
         * If this parameter is a negative value, 0 is used.
         * 
         * @return A substring based on the specified parameters.
         */
        public function substring(start:Number = 0, end:Number = int.MAX_VALUE):String 
        {
            return _string.substring(start, end);
        }
        
        /**
         * Returns a copy of this string, with all uppercase characters 
         * converted to lowercase. The original string is unmodified. While this 
         * method is intended to handle the conversion in a locale-specific way, 
         * the ActionScript 3.0 implementation does not produce a different 
         * result from the toLowerCase() method.
         * 
         * @return A copy of this string with all uppercase characters converted 
         * to lowercase.
         */
        public function toLocaleLowerCase():String 
        {
            return _string.toLocaleLowerCase();
        }
        
        /**
         * Returns a copy of this string, with all lowercase characters 
         * converted to uppercase. The original string is unmodified. While this 
         * method is intended to handle the conversion in a locale-specific way, 
         * the ActionScript 3.0 implementation does not produce a different 
         * result from the toUpperCase() method.
         * 
         * @return A copy of this string with all lowercase characters converted 
         * to uppercase.
         */
        public function toLocaleUpperCase():String 
        {
            return _string.toLocaleUpperCase();
        }
        
        /**
         * Returns a copy of this string, with all uppercase characters 
         * converted to lowercase. The original string is unmodified.
         * 
         * This method converts all characters (not simply A-Z) for which 
         * Unicode lowercase equivalents exist:
         * <codeblock>
         *   var str:String = " JOSÉ BARÇA";
         *   trace(str.toLowerCase()); // josé barça
         * </codeblock>
         * 
         * These case mappings are defined in the Unicode Character Database 
         * specification.
         * 
         * @return A copy of this string with all uppercase characters converted 
         * to lowercase.
         */
        public function toLowerCase():String 
        {
            return _string.toLowerCase();
        }
        
        /**
         * Returns a copy of this string, with all lowercase characters 
         * converted to uppercase. The original string is unmodified.
         * 
         * This method converts all characters (not simply a-z) for which 
         * Unicode uppercase equivalents exist:
         * <codeblock>
         *   var str:String = "José Barça";
         *   trace(str.toUpperCase()); // JOSÉ BARÇA
         * </codeblock>
         * 
         * These case mappings are defined in the Unicode Character Database
         * specification.
         * 
         * @return A copy of this string with all lowercase characters converted 
         * to uppercase.
         */
        public function toUpperCase():String 
        {
            return _string.toUpperCase();
        }
        
        /**
         * Returns the primitive value of a String instance. This method is 
         * designed to convert a String object into a primitive string value. 
         * Because Flash runtimes automatically call valueOf() when necessary, 
         * you rarely need to call this method explicitly.
         * 
         * @return The value of the string.
         * 
         * @oldexample The following example creates a new instance of the 
         * String class and then shows that the <code>valueOf</code> method 
         * returns the <i class="+ topic/ph hi-d/i ">primitive</i> value, rather 
         * than a reference to the new instance.
         * <codeblock>
         *   var str:String = new String("Hello World");
         *   var value:String = str.valueOf();
         *   trace(str instanceof String); // true
         *   trace(value instanceof String); // false
         *   trace(str === value); // false</listing>
         * </codeblock>
         */
        public function valueOf():String 
        {
            return _string.valueOf();
        }
        
        public function toString():String 
        {
            return _string.toString();
        }
        
        /**
         * An integer specifying the number of characters in the specified 
         * EString object.
         * 
         * Because all string indexes are zero-based, the index of the last 
         * character for any string x is x.length - 1.
         */
        public function get length():int 
        { 
            return _string.length; 
        }
        
    //----------------------------------
    //  EString implementation
    //----------------------------------
        /**
         * Checks whether the 'string' is a hex number.
         * 
         * @param string    String to be checked.
         * @return Returns  TRUE if 'string' is a hex number.
         */
        public function isHex():Boolean
        {
            return EString.isHex(_string);
        }
        
        public function prepend(slice:String, times:int):EString
        {
            _string = EString.prepend(_string, slice, times);
            return this;
        }
        
        public function append(slice:String, times:int):EString
        {
            _string = EString.append(_string, slice, times);
            return this;
        }
        
        /**
         * 
         * @param    string
         * @param    chars
         * @return
         */
        public function trim(chars:String = WHITESPACE):EString
        {
            _string = EString.trim(_string, chars);
            return this;
        }
        
        /**
         * Fills and returns template with specified values. Template is a 
         * string with value fields specifield like {N}, where N is the passed 
         * value index.
         * 
         * @param template  Template string.
         * @param ...values Values.
         * @return Returns new String filled with specified values.
         */
        public function map(...values):EString
        {
            values.unshift(_string);
            _string = EString.format.apply(null, values);
            return this;
        }
        
        public function multiply(times:int):EString
        {
            _string = EString.multiply(_string, times);
            return this
        }
    }
}