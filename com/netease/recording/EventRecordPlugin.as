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
  import flash.text.TextField;

  public final class EventRecordPlugin extends RecordPlugin
                                       implements IRecordPlugin
  {
    public function EventRecordPlugin(recordManager:BaseRecordManager)
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
      return getEventNames(Event).filter(eventFilter);
    }
    
    public function toXMLList(event:Event):XMLList
    {
      switch (event.type)
      {
        case Event.CHANGE:
        {
          return XMLList(toXML("text", TextField(event.target).text));
        }
        case Event.SCROLL:
        {
          return toXML("scrollH", event.target.scrollH) +
                 toXML("scrollV", event.target.scrollV);
        }
        // TODO: 其他状态
        default:
        {
          return XMLList(<!-- No addition data -->);
        }
      }
    }
    
  }
}