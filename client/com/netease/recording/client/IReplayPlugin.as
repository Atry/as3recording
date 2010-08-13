// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{
  import flash.events.*;
  
  public interface IReplayPlugin
  {
    function get targetType():Class;
    function newInstance(...args):IEventDispatcher;
    function get eventNames():Array;

    function toEvent(target:IEventDispatcher,
                     type:String,
                     bubbles:Boolean,
                     cancelable:Boolean,
                     xml:XML):Event;
    function beforeDispatch(xml:XML,
                            target:IEventDispatcher,
                            event:Event):void;
    function afterDispatch(xml:XML,
                           target:IEventDispatcher,
                           event:Event):void;
  }
}