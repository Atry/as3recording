// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client.utils
{
  import com.netease.recording.client.IRecorder;
  import com.netease.recording.client.ITimer;
  
  import flash.events.TimerEvent;
  
  public function setInterval(recorder:IRecorder,
                              closure:Function,
                              delay:Number,
                              ...args):uint
  {
    const id:uint = intervalTimers.length;
    const timer:ITimer = ITimer(recorder.newInstance(ITimer, delay, 0));
    timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
    {
      closure.apply(null, args);
    });
    timer.start();
    intervalTimers[id] = timer;
    return id;
  }
}
