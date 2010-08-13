// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.server
{
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.utils.Timer;
  public final class Session
  {
    public static const TIMEOUT:Number = 1000;
    public const timer:Timer = new Timer(TIMEOUT);
    public const stream:FileStream = new FileStream();
    private var _name:String;
    public function get name():String {
      return _name;
    }
    public function close():void {
      stream.writeUTFBytes('</as3replay>');
      stream.close();
      timer.stop();
    }
    public function Session(name:String) {
      _name = name
      stream.open(File.applicationStorageDirectory.resolvePath(name),
                  FileMode.WRITE);
      stream.writeUTFBytes('<?xml version="1.0" encoding="UTF-8" ?>\n');
      stream.writeUTFBytes('<as3replay>\n');
    }
  }
}