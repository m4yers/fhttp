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
package com.mayerscraft.compressing 
{
    import com.mayerscraft.hash.CRC32;
    import com.mayerscraft.lang.EBytes;
    import flash.system.Capabilities;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    /**
     * Implementation of GZIP file format
     * 
     * @see     http://www.gzip.org/zlib/rfc-gzip.html
     * @author Artyom Goncharov 28.02.2013 11:06
     */
    public class GZIP 
    {
        private static const ERR_NOT_GZIP       :String = 'The bytes is not encoded in GZIP format';
        private static const ERR_CM_UNKNOWN     :String = 'The data is compressed by unknown method.';
        private static const ERR_ENCRYPTED      :String = 'The data is encrypted, this is not supported.';
        private static const ERR_RESERVED       :String = 'The bytes has 6,7 flags set, this is not supported.';
        private static const ERR_WRONG_CRC32    :String = 'The data is corrupted crc32 does not match.';
        private static const ERR_WRONG_SIZE     :String = 'The data has wrong size.';
        
        private static const MAGIC              :uint = (0x8b << 8) | 0x1f    //ID2, ID1
        
        private static const CM_DEFLATE         :uint = 8;
        
        private static const XFL_SLOW           :uint = 2;
        private static const XFL_FAST           :uint = 4;
        
        private static const FLG_TEXT           :uint = 0x01;    // 0
        private static const FLG_HCRC           :uint = 0x02;    // 1
        private static const FLG_EXTRA          :uint = 0x04;    // 2
        private static const FLG_NAME           :uint = 0x08;    // 3
        private static const FLG_COMMENT        :uint = 0x10;    // 4
        private static const FLG_ENCRYPTION     :uint = 0x20;    // 5
        private static const FLG_RESERVED       :uint = 0xc0;    // 6, 7
        
        private static const OS:Object = 
        {
              '0': 'FAT filesystem (MS-DOS, OS/2, NT/Win32)',
              '1': 'Amiga',
              '2': 'VMS (or OpenVMS)',
              '3': 'Unix',
              '4': 'VM/CMS',
              '5': 'Atari TOS',
              '6': 'HPFS filesystem (OS/2, NT)',
              '7': 'Macintosh',
              '8': 'Z-System',
              '9': 'CP/M',
             '10': 'TOPS-20',
             '11': 'NTFS filesystem (NT)',
             '12': 'QDOS',
             '13': 'Acorn RISCOS',
            '255': 'unknown'
        }
        
        public static function isGZIP(bytes:ByteArray):Boolean
        {
            var result:Boolean;
            if (bytes)
            {
                var position:uint = bytes.position;
                bytes.position = 0;
                result = bytes.readUnsignedShort() == MAGIC;
                bytes.position = position;
            }
            return result;
        }
        
        public static function compress(bytes:ByteArray, options:Object = null):ByteArray
        {
            var result:ByteArray;
            
            if (bytes)
            {
                var crc32:uint = CRC32.calculate(bytes);
                var size:uint = bytes.length;
                
                var 
                flags:uint = 0;
                if (options)
                {
                    flags |= (options.text      ? FLG_TEXT      : 0);
                    flags |= (options.filename  ? FLG_NAME      : 0);
                    flags |= (options.comment   ? FLG_COMMENT   : 0);
                }
                
                var osname:String = String((options && options.os) || Capabilities.os);
                var os:uint = 255;
                if      (osname.indexOf('win') != -1) os = 0;
                else if (osname.indexOf('nix') != -1) os = 3;
                else if (osname.indexOf('max') != -1) os = 7;
                
                result = new ByteArray;
                result.endian = Endian.LITTLE_ENDIAN;
                result.writeShort(MAGIC);
                result.writeByte(CM_DEFLATE);
                result.writeByte(flags);
                result.writeUnsignedInt(uint((options && options.mtime) || 0));
                result.writeByte(XFL_FAST);
                result.writeByte(os);
                
                if ((flags & FLG_NAME) != 0x00)
                {
                    result.writeUTFBytes(options.filename);
                    result.writeByte(0);
                }
                
                if ((flags & FLG_COMMENT) != 0x00)
                {
                    result.writeUTFBytes(options.comment);
                    result.writeByte(0);
                }
                
                bytes = EBytes.clone(bytes);
                bytes.position = 0;
                bytes.deflate();
                
                result.writeBytes(bytes, 0, 0);
                result.writeUnsignedInt(crc32);
                result.writeUnsignedInt(size);
            }
            
            return result;
        }
        
        public static function decompress(bytes:ByteArray):Object
        {
            bytes.position = 0;
            bytes.endian = Endian.LITTLE_ENDIAN;
            
            var error   :String;
            var data    :ByteArray;
            var buffer  :ByteArray;
            var cm      :uint;
            var flags   :uint;
            var mtime   :uint;
            var xfl     :uint;
            var os      :uint;
            var extra   :ByteArray;
            var filename:String;
            var comment :String;
            var hcrc    :uint;
            var crc32   :uint;
            var size    :uint;
            
            if (bytes.readUnsignedShort() != MAGIC)
            {
                error = ERR_NOT_GZIP;
            }
            else
            {
                cm = bytes.readUnsignedByte();
                
                if (cm != CM_DEFLATE)
                {
                    error = ERR_CM_UNKNOWN;
                }
                else
                {
                    flags = bytes.readUnsignedByte();
                    
                    if ((flags & FLG_RESERVED) != 0)
                    {
                        error = ERR_RESERVED;
                    }
                    else if ((flags & FLG_ENCRYPTION) != 0)
                    {
                        error = ERR_ENCRYPTED;
                    }
                    else
                    {
                        mtime = bytes.readUnsignedInt();
                        xfl = bytes.readByte();
                        os = bytes.readByte();
                        
                        if ((flags & FLG_EXTRA) != 0x00)
                            bytes.readBytes(extra = new ByteArray, 0, bytes.readUnsignedShort());
                        
                        if ((flags & FLG_NAME) != 0x00)
                            filename = EBytes.read(bytes, null, [ 0x00 ]).toString();
                        
                        if ((flags & FLG_COMMENT) != 0x00)
                            comment = EBytes.read(bytes, null, [ 0x00 ]).toString();    
                            
                        if ((flags & FLG_HCRC) != 0x00)
                            hcrc = bytes.readUnsignedShort();
                            
                        data = EBytes.readBody(bytes, null, bytes.bytesAvailable - 8);
                        data.inflate();
                        
                        crc32 = bytes.readUnsignedInt();
                        size = bytes.readUnsignedInt();
                        
                        if (CRC32.calculate(data) != crc32)
                            error = ERR_WRONG_CRC32;
                        else if (data.length != size)
                            error = ERR_WRONG_SIZE;
                    }
                }
            }
            
            var result:Object = 
            {
                filename: filename,
                    size: size,
                    data: data,
                   mtime: mtime,
                 comment: comment
            }
            
            if (os.toString() in OS)
                result.os = OS[os.toString()]
            else
                result.os = OS['255'];
            
            if (error)
                result.error = error;
            
            return result;
        }
    }
}