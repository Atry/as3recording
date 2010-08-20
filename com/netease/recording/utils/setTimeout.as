// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.utils
{
  import com.netease.recording.IRecorder;
  import com.netease.recording.ITimer;
  
  import flash.events.TimerEvent;
  
  public function setTimeout(recorder:IRecorder,
                             closure:Function,
                             delay:Number,
                             ...args):uint
  {
    const id:uint = timeoutTimers.length;
    const timer:ITimer = recorder.newInstance(ITimer, delay, 1);
    timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void
    {
      closure.apply(null, args);
    });
    timer.start();
    timeoutTimers[id] = timer;
    return id;
  }
}

var seed:uint = 1;