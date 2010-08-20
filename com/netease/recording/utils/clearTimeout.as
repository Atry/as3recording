// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.utils
{
  import com.netease.recording.ITimer;
  
  public function clearTimeout(id:uint):void
  {
    const timer:ITimer = timeoutTimers[id];
    timer.stop();
    do
    {
      delete timeoutTimers[id];
    }
    while (timeoutTimers[id]); 
  }
}
