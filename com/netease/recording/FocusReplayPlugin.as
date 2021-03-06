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

  public final class FocusReplayPlugin extends ReplayPlugin
                                       implements IReplayPlugin
  {
    public function FocusReplayPlugin(replayManager:BaseReplayManager)
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
      return getEventNames(FocusEvent);
    }
    
    override public function beforeDispatch(xml:XML,
                                            target:IEventDispatcher,
                                            event:Event):void
    {
      manager.stage.focus = toInteractiveObject(xml.focus);
    }

    public function toEvent(target:IEventDispatcher,
                            type:String,
                            bubbles:Boolean,
                            cancelable:Boolean,
                            xml:XML):Event
    {
      const result:FocusEvent = Capabilities.playerType == "Desktop" ?
        new (FocusEvent)(// 避免类型检查
          type,
          bubbles,
          cancelable,
          null, // 无法记录 relatedObject
          toBoolean(xml.shiftKey),
          xml.keyCode,
          xml.direction) :
        new FocusEvent(
          type,
          bubbles,
          cancelable,
          null, // 无法记录 relatedObject
          toBoolean(xml.shiftKey),
          xml.keyCode);
      result.isRelatedObjectInaccessible = true;
      return result;
    }
    
  }
}