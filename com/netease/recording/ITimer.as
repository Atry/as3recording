// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.events.IEventDispatcher;
  
  /**
   * @copy flash.utils.Timer.timer
   */
  [Event(type="flash.events.TimerEvent", name="timer")]
  /**
   * @copy flash.utils.Timer.timerComplete
   */
  [Event(type="flash.events.TimerEvent", name="timerComplete")]
  /**
   * @copy flash.utils.Timer
   */
  public interface ITimer extends IEventDispatcher
  {
    /**
     * @copy flash.utils.Timer.currentCount
     */
    function get currentCount():int;
    
    /**
     * @copy flash.utils.Timer.delay
     */
    function get delay():Number;
    
    function set delay(value:Number):void;
    
    [Bindable(event="timer")]
    /**
     * @copy flash.utils.Timer.repeatCount
     */
    function get repeatCount():int;
    
    function set repeatCount(value:int):void;
    
    /**
     * @copy flash.utils.Timer.running
     */
    function get running():Boolean;
    
    /**
     * @copy flash.utils.Timer.reset()
     */
    function reset():void;
    
    /**
     * @copy flash.utils.Timer.start()
     */
    function start():void;
    
    /**
     * @copy flash.utils.Timer.stop()
     */
    function stop():void;

  }
}