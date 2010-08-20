// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.events.*;
  
  public interface IRecordPlugin
  {
    function get targetType():Class;
    function newInstance(...args):*;
    function get eventNames():Array;

    function toXMLList(event:Event):XMLList;
  }
}