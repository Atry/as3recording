// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client.utils
{
  import com.netease.recording.client.ITimer;
    
  public function clearInterval(id:uint):void
  {
    const timer:ITimer = intervalTimers[id];
    timer.stop();
    do
    {
      delete intervalTimers[id];
    }
    while (intervalTimers[id]); 
  }
}
