// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.net.URLRequest;
  
  public class ReplayManager extends BaseReplayManager
  {
    public function ReplayManager(urlRequest:URLRequest)
    {
      super(urlRequest);
      addPlugin(new EventReplayPlugin(this));
      addPlugin(new MouseReplayPlugin(this));
      addPlugin(new KeyboardReplayPlugin(this));
      addPlugin(new FocusReplayPlugin(this));
      addPlugin(new TextReplayPlugin(this));
      
      addPlugin(new LoaderInfoReplayPlugin(this));
      addPlugin(new LoaderReplayPlugin(this));
      addPlugin(new TimerReplayPlugin(this));
    }
    
  }
}