// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.events.Event;
  public function eventFilter(eventName:String,
                              index:int,
                              a:Array):Boolean
  {
    switch (eventName)
    {
      case Event.ADDED:
      case Event.ADDED_TO_STAGE:
      case Event.REMOVED:
      case Event.REMOVED_FROM_STAGE:

      case Event.COMPLETE:
      case Event.OPEN:
      case Event.UNLOAD:

      case Event.ACTIVATE:
      case Event.DEACTIVATE:

      case Event.RENDER:
      case Event.ENTER_FRAME:
      case Event.EXIT_FRAME:
      case Event.FRAME_CONSTRUCTED:
      {
        return false;
      }
      default:
      {
        return true;
      }
    }
  }
}