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
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * 
     * @author    MaYeRs    28.02.2013 18:59
     */
    public class EMath 
    {
        private static const DEGCOEF:Number = 180.0 / Math.PI;
        private static const RADCOEF:Number = Math.PI / 180.0;
        
        public static function toDegrees(value:Number):Number 
        {
            return DEGCOEF * value;
        }
        
        public static function toRadians(value:Number):Number 
        {
            return RADCOEF * value;
        }
        
        public static function getPower(number:Number):Number
        {
            return Math.log(number) / Math.log(2)
        }
        
        public static function getRandom(min:Number, max:Number):Number 
        {
            return Math.random() * (max-min) + min;
        }
        
        public static function getDistance2D(pointA:Point, pointB:Point):Number 
        {
            var dx:Number = pointA.x - pointB.x;
            var dy:Number = pointA.y - pointB.y;
            return Math.sqrt(dx * dx + dy * dy);
        }
        
        public static function getDistance2DPrimitive(ax:Number, ay:Number, bx:Number, by:Number):Number 
        {
            var dx:Number = ax - bx;
            var dy:Number = ay - by;
            return Math.sqrt(dx * dx + dy * dy);
        }
        
        public static function getAngle2D(pointA:Point, pointB:Point):Number
        {
            return Math.atan2(pointA.y - pointB.y, pointA.x - pointB.x);
        }
        
        public static function getRandomPointOnLine2D(pointA:Point, pointB:Point):Point 
        {
            var dx            :Number = pointA.x - pointB.x;
            var dy            :Number = pointA.y - pointB.y;
            var distance    :Number = getRandom(0, getDistance2D(pointA, pointB));
            var angle        :Number = Math.atan2(dy, dx);
            return new Point(Math.round(Math.cos(angle) * distance + pointA.x - dx), Math.round(Math.sin(angle) * distance + pointA.y - dy));
        }
        
        public static function getRandomPointOnPoligon2D(array:Array):Point         //only for convex    // more random
        {
            var points        :Array = array;
            var indexA        :uint = Math.round(getRandom(0, points.length - 1));
            var pointA        :Point = getRandomPointOnLine2D(points[indexA], (indexA == points.length - 1)? points[0]: points[indexA + 1]); 
            points.slice(indexA, 1);
            var indexB        :uint = Math.round(getRandom(0, points.length - 1));
            var pointB        :Point = getRandomPointOnLine2D(points[indexB], (indexB == 0)? points[points.length - 1]: points[indexB - 1]);
            return getRandomPointOnLine2D(pointA, pointB);
        }
        
        /*public static function getRandomPointOnPoligon2D(...points):Point {    //only for convex    // less random
            var index        :uint = Math.round(getRandom(0, points.length - 1));
            //var indexB        :uint = Math.round(getRandom(0, points.length - 1));
            return getRandomPointInLine2D(getRandomPointInLine2D(points[index], (index == points.length-1)? points[0]: points[index + 1]), 
                                          getRandomPointInLine2D(points[index], (index == 0)? points[points.length-1]: points[index - 1]));
        }*/
        
    //--------------------------------------------------------------------------
    //
    //  Curves
    //
    //--------------------------------------------------------------------------
    //----------------------------------
    //  bezier
    //----------------------------------
        public static function generateCubicBezierCurvePoints(a:Point, b:Point, c:Point, d:Point, step:Number):Vector.<Point>
        {
            var result    :Vector.<Point> = new <Point>[];
            var period    :Number;
            var t        :Number
            
            for (t = 0.0; t < 1.0; t += step) 
            {
                period = 1.0 - t;
                
                result.push
                (
                    new Point(period * period * period * a.x + 3.0 * t * period * period * b.x + 3 * t * t * period * c.x + t * t * t * d.x,
                              period * period * period * a.y + 3.0 * t * period * period * b.y + 3 * t * t * period * c.y + t * t * t * d.y)
                );
            }
            
            result.push(d);
            
            return result;
        }
        
        public static function generateCubicBezierCurvePoints2(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number, step:Number):Array
        {
            var result    :Array = [];
            var period    :Number;
            var t        :Number
            
            for (t = 0.0; t < 1.0; t += step) 
            {
                period = 1.0 - t;
                
                result.push
                (
                    period * period * period * ax + 3.0 * t * period * period * bx + 3 * t * t * period * cx + t * t * t * dx,
                    period * period * period * ay + 3.0 * t * period * period * by + 3 * t * t * period * cy + t * t * t * dy
                );
            }
            
            result.push(dx, dy);
            
            return result;
        }
        
        public static function generateQuarticBezierCurvePoints(a:Point, b:Point, c:Point, d:Point, e:Point, step:Number):Vector.<Point>
        {
            var result    :Vector.<Point> = new <Point>[];
            var period    :Number;
            var t        :Number
            
            for (t = 0.0; t < 1.0; t += step) 
            {
                period = 1.0 - t;
                
                result.push
                (
                    new Point(a.x * period * period * period * period + 4.0 * b.x * t * period * period * period + 6.0 * c.x * t * t * period * period + 4.0 * d.x * t * t * t * period + e.x * t * t * t * t,
                              a.y * period * period * period * period + 4.0 * b.y * t * period * period * period + 6.0 * c.y * t * t * period * period + 4.0 * d.y * t * t * t * period + e.y * t * t * t * t)
                );
            }
            
            result.push(d);
            
            return result;
        }
        
        public static function generateQuarticBezierCurvePoints2(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number, ex:Number, ey:Number, step:Number):Array
        {
            var result    :Array = [];
            var period    :Number;
            var t        :Number
            
            for (t = 0.0; t < 1.0; t += step) 
            {
                period = 1.0 - t;
                
                result.push
                (
                    ax * period * period * period * period + 4.0 * bx * t * period * period * period + 6.0 * cx * t * t * period * period + 4.0 * dx * t * t * t * period + ex * t * t * t * t,
                    ay * period * period * period * period + 4.0 * by * t * period * period * period + 6.0 * cy * t * t * period * period + 4.0 * dy * t * t * t * period + ey * t * t * t * t
                );
            }
            
            result.push(ex, ey);
            
            return result;
        }
        
    //--------------------------------------------------------------------------
    //
    //  Misc
    //
    //--------------------------------------------------------------------------
        /**
         * 
         * @param    left    Left bound.
         * @param    right    Right bound.
         * @return    Returns an array filled with values between left and right
         * bounds including the arguments.
         */
        public static function rangeInt(left:int, right:int):Array
        {
            var result:Array = [];
            var l:int = left < right ? left : right;
            var r:int = left < right ? right : left;
            
            if (l < r)
            {
                for (var i:int = l + 1; i < r; i++) 
                    result.push(i);
            }
            
            result.unshift(l);
            result.push(r);
            
            if (left > right)
                result.reverse();
                
            return result;
        }
        
        /**
         * 
         * @param    left    Left bound.
         * @param    right    Right bound.
         * @param    step    Step of iterations.
         * @return    Returns an array filled with values between left and right
         * bounds including the arguments.
         */
        public static function rangeNumber(left:Number, right:Number, step:Number):Array
        {
            var result:Array = [];
            var l:int = left < right ? left : right;
            var r:int = left < right ? right : left;
            
            if (l < r)
            {
                for (var i:Number = l; i < r; i+=step) 
                    result.push(i);
            }
            
            result.unshift(l);
            result.push(r);
            
            if (left > right)
                result.reverse();
                
            return result;
        }
    }
}