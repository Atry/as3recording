// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{
  public class ReplayManager extends BaseReplayManager
  {
    public function ReplayManager(connectionName:String, replayName:String)
    {
      super(connectionName, replayName);
      addPlugin(new EventReplayPlugin(this));
      addPlugin(new MouseReplayPlugin(this));
      addPlugin(new KeyboardReplayPlugin(this));
      addPlugin(new FocusReplayPlugin(this));
      addPlugin(new TextReplayPlugin(this));

      addPlugin(new TimerReplayPlugin(this));
    }
    
  }
}