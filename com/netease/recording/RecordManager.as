// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.Stage;
  import flash.errors.IllegalOperationError;
  import flash.events.EventPhase;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.system.Capabilities;
  import flash.text.TextField;
  import flash.utils.describeType;
  
  public class RecordManager extends BaseRecordManager
  {
    public function RecordManager()
    {
      addPlugin(new EventRecordPlugin(this));
      addPlugin(new MouseRecordPlugin(this));
      addPlugin(new KeyboardRecordPlugin(this));
      addPlugin(new FocusRecordPlugin(this));
      addPlugin(new TextRecordPlugin(this));
      
      addPlugin(new LoaderInfoRecordPlugin(this));
      addPlugin(new LoaderRecordPlugin(this));
      addPlugin(new TimerRecordPlugin(this));
    }

  }
}