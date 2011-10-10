package com.netease.recording
{
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.net.Socket;
  import flash.net.URLRequestHeader;
  import flash.system.Capabilities;
  import flash.utils.ByteArray;
  import flash.utils.Endian;
  
  /**
   * 通过HTTP协议的POST或PUT方法向服务器传送数据。
   * 
   * <p>
   * 和<code>flash.net.URLLoader</code>相比，
   * ChunkedHTTPPoster支持分段多次发送HTTP数据，
   * 而不是必须把所有数据放在一个内存缓冲区中。
   * </p>
   */
  public final class ChunkedHTTPPoster extends Socket
  {
    private var urlRequest:PosterURLRequest;
    
    private var gzipEnabled:Boolean;
    
    private static const DEFAULT_REQUEST_HEADER:Object =
    {
      "User-Agent": "HTTPPoster",
      "Content-Type": "text/xml;charset=utf-8"
    }
    
    private function connectHandler(event:Event):void
    {
      endian = Endian.LITTLE_ENDIAN;
      const captures:Array = urlRequest.url.match(
        /http:\/\/(([^\/:@]+)(:(.+))?@)?([^\/:]+)(:([^\/]+))?(\/?.*)/);
      const userid:String = captures[2];
      const password:String = captures[4];
      const host:String = captures[5];
      const port:uint = captures[7] || 80;
      const path:String = captures[8];
      writeUTFBytes(
        urlRequest.method + " " + path + " HTTP/1.1\r\n");
      if (userid)
      {
        throw new ArgumentError("HTTP authentication unimplemented.");
      }
      const requestHeaders:Object =
      {
        "Host": host,
        "Transfer-Encoding": "chunked",
        "Connection": "close"
      };
      if (urlRequest.requestHeaders)
      {
        for each(var header:URLRequestHeader in urlRequest.requestHeaders)
        {
          if (header.name in requestHeaders)
          {
            throw new IllegalOperationError();
          }
          requestHeaders[header.name] = header.value;
        }
      }
      for (var defaultName:String in DEFAULT_REQUEST_HEADER)
      {
        if (!(defaultName in requestHeaders))
        {
          requestHeaders[defaultName] =
            DEFAULT_REQUEST_HEADER[DEFAULT_REQUEST_HEADER];
        }
      }
      switch (requestHeaders["Content-Encoding"])
      {
        case "gzip":
        {
          gzipEnabled = true;
          break;
        }
        case undefined:
        case "identity":
        {
          break;
        }
        default:
        {
          throw new IllegalOperationError();
        }
      }
      for (var name:String in requestHeaders)
      {
        writeUTFBytes(name + ":" + requestHeaders[name] + "\r\n");
      }
      writeUTFBytes("\r\n");
    }
    
    public function ChunkedHTTPPoster()
    {
      addEventListener(Event.CONNECT, connectHandler);
    }
    
    public function open(urlRequest:PosterURLRequest):void
    {
      this.urlRequest = urlRequest;
      const captures:Array = urlRequest.url.match(
        /http:\/\/(([^\/:@]+)(:(.+))?@)?([^\/:]+)(:([^\/]+))?(\/?.*)/);
      if (!captures)
      {
        throw new ArgumentError();
      }
      const host:String = captures[5];
      const port:uint = captures[7];
      connect(host, port);
    }
    
    
    /** The fast CRC table. Computed once when the CRC32 class is loaded. */
    private static var CRC_TABLE:Array = makeCrcTable();
    
    public static function crc32Checksum(data:ByteArray, start:uint = 0, len:uint = 0):uint {
      if (start >= data.length)
      {
        start = data.length;
      }
      if (len == 0)
      {
        len = data.length - start;
      }
      if (len + start > data.length)
      {
        len = data.length - start;
      }
      var i:uint;
      var c:uint = 0xffffffff;
      for (i = start; i < len; i++)
      {
        c = uint(CRC_TABLE[(c ^ data[i]) & 0xff]) ^ (c >>> 8);
      }
      return (c ^ 0xffffffff);
    }
    
    /**
     * 生成CRC表
     * @return CRC表
     */
    private static function makeCrcTable():Array {
      var crcTable:Array = [];
      for (var n:int = 0; n < 256; n++)
      {
        var c:uint = n;
        for (var k:int = 8; --k >= 0; )
        {
          if ((c & 1) != 0) c = 0xedb88320 ^ (c >>> 1);
          else c = c >>> 1;
        }
        crcTable[n] = c;
      }
      return crcTable;
    }
    
    public function writeLastChunk():void
    {
      writeUTFBytes("0\r\n\r\n");
      flush();
    }

    /**
     * @param bytes 如果为空代表关闭
     */ 
    public function writeChunk(bytes:ByteArray):void
    {
      if (bytes.length > 0)
      {
        if (gzipEnabled)
        {
          const crc32:uint = crc32Checksum(bytes);
          const isize:uint = bytes.length % Math.pow(2, 32);
          bytes.deflate();
          writeUTFBytes((18 + bytes.length).toString(16));
          writeUTFBytes("\r\n");
          const id1:uint = 31;
          writeByte(id1);
          const id2:uint = 139;
          writeByte(id2);
          const cm:uint = 8;
          writeByte(cm);
          const flags:int = 0;
          writeByte(flags);
          const mtime:uint = new Date().time / 1000;
          writeUnsignedInt(mtime);
          const xfl:uint = 4;
          writeByte(xfl);
          const os:uint =
            Capabilities.os.indexOf("Windows") != -1 ? 11 :// NTFS
            Capabilities.os.indexOf("Mac OS") != -1 ? 7 :// Macintosh
            3;//Unix
          writeByte(os);
          writeBytes(bytes);
          writeUnsignedInt(crc32);
          writeUnsignedInt(isize);
          writeUTFBytes("\r\n");
        }
        else
        {
          writeUTFBytes((bytes.length).toString(16));
          writeUTFBytes("\r\n");
          writeBytes(bytes);
          writeUTFBytes("\r\n");
        }
        flush();
      }
    }
  }
}