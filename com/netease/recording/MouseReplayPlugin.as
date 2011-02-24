// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.DisplayObject;
  import flash.display.InteractiveObject;
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.system.Capabilities;

  public class MouseReplayPlugin extends ReplayPlugin implements IReplayPlugin
  {
    public function MouseReplayPlugin(replayManager:BaseReplayManager)
    {
      super(replayManager);
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
    
    public function toEvent(target:IEventDispatcher,
                            type:String,
                            bubbles:Boolean,
                            cancelable:Boolean,
                            xml:XML):Event
    {
      const stageX:Number = xml.stageX;
      const stageY:Number = xml.stageY;
      const localPoint:Point = DisplayObject(target).
          globalToLocal(new Point(stageX, stageY));
      const result:MouseEvent = Capabilities.playerType == "Desktop" ?
        new (MouseEvent)(// 避免类型检查
          type,
          bubbles,
          cancelable,
          localPoint.x,
          localPoint.y,
          null, // 无法记录 relatedObject
          toBoolean(xml.ctrlKey),
          toBoolean(xml.altKey),
          toBoolean(xml.shiftKey),
          toBoolean(xml.buttonDown),
          xml.delta,
          toBoolean(xml.commandKey),
          toBoolean(xml.controlKey),
          xml.clickCount) :
        new MouseEvent(
          type,
          bubbles,
          cancelable,
          localPoint.x,
          localPoint.y,
          null, // 无法记录 relatedObject
          toBoolean(xml.ctrlKey),
          toBoolean(xml.altKey),
          toBoolean(xml.shiftKey),
          toBoolean(xml.buttonDown),
          xml.delta);
      result.isRelatedObjectInaccessible = true;
      return result;
    }
    
  }
}