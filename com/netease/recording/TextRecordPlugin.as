// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.events.TextEvent;

  public class TextRecordPlugin extends RecordPlugin implements IRecordPlugin
  {
    public function TextRecordPlugin(recordManager:BaseRecordManager)
    {
      super(recordManager);
    }
    
    public function get targetType():Class
    {
      return null;
    }
    
    public function newInstance(...args):*
    {
      throw new IllegalOperationError();
    }

    public function get eventNames():Array
    {
      return getEventNames(TextEvent);
    }

    public function toXMLList(event:Event):XMLList
    {
      const textEvent:TextEvent = TextEvent(event);
      return XMLList(toXML("text", textEvent.text));
    }
    
  }
}