// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.events.TimerEvent;

  public class TimerReplayPlugin extends ReplayPlugin implements IReplayPlugin
  {
    public function TimerReplayPlugin(manager:ReplayManager)
    {
      super(manager);
    }

    public function get targetType():Class
    {
      return ITimer;
    }
    
    public function newInstance(...args):IEventDispatcher
    {
      return new ReplayTimer(args[0], args[1]);
    }
    
    public function get eventNames():Array
    {
      return getEventNames(TimerEvent);
    }
    
    override public function beforeDispatch(xml:XML,
                                            target:IEventDispatcher,
                                            event:Event):void
    {
      ReplayTimer(target).timer_internal::currentCount = xml.currentCount;
    } 
    
    public function toEvent(target:IEventDispatcher,
                            type:String,
                            bubbles:Boolean,
                            cancelable:Boolean,
                            xml:XML):Event
    {
      return new TimerEvent(type, bubbles, cancelable);
    }
    
  }
}
import flash.utils.Timer;
import com.netease.recording.client.ITimer;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;

namespace timer_internal;
  
final class ReplayTimer extends EventDispatcher implements ITimer
{
  private var _currentCount:int;
  
  public function get currentCount():int
  {
    return _currentCount;
  }
  
  timer_internal function set currentCount(value:int):void
  {
    _currentCount = value
  }
  
  private var _delay:Number;
   
  public function get delay():Number
  {
    return _delay;
  }
    
  public function set delay(value:Number):void
  {
    _delay = delay;
  }
  
  private var _repeatCount:int;

  public function get repeatCount():int
  {
    return _repeatCount;
  }
    
  public function set repeatCount(value:int):void
  {
    _repeatCount = value;
  }

  public function ReplayTimer(delay:Number, repeatCount:uint = 0)
  {
    _delay = delay;
    _repeatCount = repeatCount;
  }

  private var _running:Boolean;
  
  public function get running():Boolean
  {
    return _running;
  }

  public function reset():void
  {
    _currentCount = 0;
    _running = false;
  }
    
  public function start():void
  {
    _running = true;
  }
    
  public function stop():void
  {
    _running = false;
  }
}