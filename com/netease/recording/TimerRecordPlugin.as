// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.events.TimerEvent;
  import flash.utils.Timer;

  public class TimerRecordPlugin extends RecordPlugin implements IRecordPlugin
  {
    public function TimerRecordPlugin(manager:RecordManager)
    {
      super(manager);
    }

    public function get targetType():Class
    {
      return ITimer;
    }
    
    public function newInstance(...args):*
    {
      return new RecordTimer(args[0], args[1]);
    }
    
    public function get eventNames():Array
    {
      return getEventNames(TimerEvent);
    }
    
    public function toXMLList(event:Event):XMLList
    {
      return XMLList(<currentCount>
                       {Timer(event.target).currentCount}
                     </currentCount>);
    }
    
  }
}
import flash.utils.Timer;
import com.netease.recording.ITimer;
  
final class RecordTimer extends Timer implements ITimer
{
  public function RecordTimer(delay:Number, repeatCount:uint = 0)
  {
    super(delay, repeatCount);
  }
}