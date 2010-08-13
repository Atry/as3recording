// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.text.TextField;

  public final class EventReplayPlugin extends ReplayPlugin
                                       implements IReplayPlugin
  {
    public function EventReplayPlugin(replayManager:BaseReplayManager)
    {
      super(replayManager);
    }
    
    public function get targetType():Class
    {
      return null;
    }
    
    public function newInstance(...args):IEventDispatcher
    {
      throw new IllegalOperationError();
    }

    public function get eventNames():Array
    {
      return getEventNames(Event).filter(eventFilter);
    }
    
    override public function beforeDispatch(xml:XML,
                                            target:IEventDispatcher,
                                            event:Event):void
    {
      switch (event.type)
      {
        case Event.CHANGE:
        {
          TextField(target).text = xmlToString(xml.text);
          break;
        }
        case Event.SCROLL:
        {
          with (target)
          {
            scrollH = xml.scrollH;
            scrollV = xml.scrollV;
          }
          break;
        }
        default:
        {
          break;
        }
      }
    }

    public function toEvent(target:IEventDispatcher,
                            type:String,
                            bubbles:Boolean,
                            cancelable:Boolean,
                            xml:XML):Event
    {
      return new Event(type, bubbles, cancelable);
    }
    
  }
}