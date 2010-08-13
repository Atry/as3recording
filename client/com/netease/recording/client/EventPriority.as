// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{
  public final class EventPriority
  {
    public static const MANAGER_CAPTURE:int = int.MAX_VALUE;
    
    public static const INSTANCE_CAPTURE:int = int.MAX_VALUE - 1;
    
    public static const MANAGER_EXIT:int = int.MIN_VALUE;

  }
}