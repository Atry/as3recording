// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.events.IEventDispatcher;
  
  [Event(type="flash.events.TimerEvent", name="timer")]
  [Event(type="flash.events.TimerEvent", name="timerComplete")]
  public interface ITimer extends IEventDispatcher
  {
    function get currentCount():int;
    
    function get delay():Number;
    
    function set delay(value:Number):void;
    
    function get repeatCount():int;
    
    function set repeatCount(value:int):void;
    
    function get running():Boolean;

    function reset():void;
    
    function start():void;
    
    function stop():void;

  }
}