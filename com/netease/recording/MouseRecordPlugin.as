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
  import flash.events.MouseEvent;
  import flash.system.Capabilities;

  public class MouseRecordPlugin extends RecordPlugin implements IRecordPlugin
  {
    public function MouseRecordPlugin(recordManager:BaseRecordManager)
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
      return getEventNames(MouseEvent);
    }

    public function toXMLList(event:Event):XMLList
    {
      const mouseEvent:MouseEvent = MouseEvent(event);
      return toXML("stageX", mouseEvent.stageX) +
             toXML("stageY", mouseEvent.stageY) +
             // 无法记录 relatedObject
             //displayObjectToXML("relatedObject", mouseEvent.relatedObject) +
             toXML("ctrlKey", mouseEvent.ctrlKey) +
             toXML("altKey", mouseEvent.altKey) +
             toXML("shiftKey", mouseEvent.shiftKey) +
             toXML("buttonDown", mouseEvent.buttonDown) +
             toXML("delta", mouseEvent.delta) +
             (Capabilities.playerType == "Desktop" ?
                 toXML("controlKey", mouseEvent["controlKey"]) +
                 toXML("commandKey", mouseEvent["commandKey"]) +
                 toXML("clickCount", mouseEvent["clickCount"]) :
                 <!-- No AIR properties -->);
    }
    
  }
}