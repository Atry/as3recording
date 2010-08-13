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
  import flash.events.KeyboardEvent;
  import flash.system.Capabilities;

  public class KeyboardRecordPlugin extends RecordPlugin
                                    implements IRecordPlugin
  {
    public function KeyboardRecordPlugin(recordManager:BaseRecordManager)
    {
      super(recordManager);
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
      return getEventNames(KeyboardEvent);
    }

    public function toXMLList(event:Event):XMLList
    {
      const keyboardEvent:KeyboardEvent = KeyboardEvent(event)
      return toXML("charCode", keyboardEvent.charCode) +
             toXML("keyCode", keyboardEvent.keyCode) +
             toXML("keyLocation", keyboardEvent.keyLocation) +
             toXML("ctrlKey", keyboardEvent.ctrlKey) +
             toXML("altKey", keyboardEvent.altKey) +
             toXML("shiftKey", keyboardEvent.shiftKey) +
             toXML("altKey", keyboardEvent.altKey) +
             (Capabilities.playerType == "Desktop" ?
                 toXML("controlKey", keyboardEvent["controlKey"]) +
                 toXML("commandKey", keyboardEvent["commandKey"]) :
                 <!-- No AIR properties -->);
    }
    
  }
}