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
  import flash.events.FocusEvent;
  import flash.events.IEventDispatcher;
  import flash.system.Capabilities;

  public class FocusRecordPlugin extends RecordPlugin
                                 implements IRecordPlugin
  {
    public function FocusRecordPlugin(recordManager:BaseRecordManager)
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
      return getEventNames(FocusEvent);
    }
    
    public function toXMLList(event:Event):XMLList
    {
      const focusEvent:FocusEvent = FocusEvent(event)
      return (
          displayObjectToXML("focus", manager.stage.focus) +
          // 无法记录 relatedObject
          //displayObjectToXML("relatedObject", focusEvent.relatedObject) +
          toXML("shiftKey", focusEvent.shiftKey) +
          toXML("keyCode", focusEvent.keyCode) +
          (Capabilities.playerType == "Desktop" ?
              toXML("direction", focusEvent["direction"]) :
              <!-- No AIR properties -->));
    }
    
  }
}