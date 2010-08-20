// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.Stage;
  public interface IRecorder
  {
    function newInstance(type:Class, ...args):*;

    function start(stage:Stage, eventPriority:int=10000):void

    function stop():void

    function get running():Boolean
    
  }
}