// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{

  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Stage;
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.EventPhase;
  import flash.events.IEventDispatcher;
  import flash.net.LocalConnection;
  import flash.utils.ByteArray;
  import flash.utils.Dictionary;
  import flash.utils.getDefinitionByName;
  
  [Event(type="com.netease.recording.client.ReplayEvent", name="notFound")]
  [Event(type="com.netease.recording.client.ReplayEvent", name="complete")]
  public class BaseReplayManager extends EventDispatcher implements IRecorder
  {
    
    private var seed:uint = 0;

    private const idsOfObject:Dictionary = new Dictionary(true);

    private function registerObject(object:Object):void
    {
      idsOfObject[object] = seed++;
    }
    
    private var globalHandlers:Object = {}

    private var instanceHandlers:Dictionary = new Dictionary();

    public final function addPlugin(plugin:IReplayPlugin):void {
      if (!plugin.targetType)
      {
        const handlers:PluginData = new PluginData(this, plugin);
        for each (var eventName:String in handlers.plugin.eventNames)
        {
          if (eventName in globalHandlers)
          {
            throw new ArgumentError();
          }
          globalHandlers[eventName] = handlers;
        }
      }
      else
      { 
        if (plugin.targetType in instanceHandlers)
        {
          throw new ArgumentError();
        }
        instanceHandlers[plugin.targetType] = new PluginData(this, plugin);
      }
    }
    
    public final function newInstance(type:Class, ...args):IEventDispatcher
    {
      const product:IEventDispatcher =
          PluginData(instanceHandlers[type]).plugin.
          newInstance.apply(null, args);
      if (running)
      {
        const pluginHandlers:PluginData = instanceHandlers[type];
        for each (var eventName:String in pluginHandlers.plugin.eventNames)
        {
          product.addEventListener(eventName,
                                   pluginHandlers.handler,
                                   true,
                                   EventPriority.MANAGER_CAPTURE);
          product.addEventListener(eventName,
                                   pluginHandlers.handler,
                                   false,
                                   EventPriority.MANAGER_CAPTURE);
        }
        registerObject(product);
      }
      return product;
    }

    private var _stage:Stage;
    
    public final function get stage():Stage
    {
      return _stage;
    }

    private var frameChanged:Boolean = false;

    private var frameCount:uint = 0;

    private var framePhase:String;

    private function enterFrameHandler(event:Event):void
    {
      if (event.eventPhase != EventPhase.AT_TARGET)
      {
        throw new IllegalOperationError();
      }
      if (replay_internal::locked)
      {
        // 由代码触发的事件，应该无视
        return;
      }
      lock();
      //try
      //{
        if (framePhase != event.type)
        {
          if (event.type == Event.ENTER_FRAME)
          {
            frameCount++;
          }
          frameChanged = true;
          framePhase = event.type;
        }
        event.stopImmediatePropagation();
        if (!IEventDispatcher(event.target).dispatchEvent(event))
        {
          event.preventDefault();
        }
        const frameElement:XML = eventList[eventIndex];
        if (frameElement.name() != "frame")
        {
          throw new IllegalOperationError();
        }
        const waitFor:uint = uint(String(frameElement.@n));
        if (frameCount > waitFor)
        {
          throw new IllegalOperationError();
        }
        if (framePhase == frameElement.@phase &&
            frameCount == waitFor)
        {
          eventIndex++;
          for (;;)
          {
            if (eventList.length() <= eventIndex)
            {
              stop();
              dispatchEvent(new ReplayEvent(ReplayEvent.COMPLETE));
              break;
            }
            else
            {
              const eventElement:XML = eventList[eventIndex];
              if (eventElement.name() == "frame")
              {
                break;
              }
              else
              {
                eventIndex++;
                processReplayEvent(eventElement);
              }
            }
          }
        }
      //}
      //finally
      //{
        unlock();
      //}
    }
    
    private static function toBoolean(xml:XMLList):Boolean
    {
      if (xml.length() == 0)
      {
        return false;
      }
      const text:String = xml.text()
      if (text == "" || text == "false")
      {
        return false;
      }
      else
      {
        return true;
      }
    }
    
    private function processReplayEvent(eventElement:XML):void
    {
      const eventType:String = eventElement.name();
      const targetType:String = eventElement.@targetType;
      const pluginData:PluginData =
          targetType ?
          instanceHandlers[getDefinitionByName(targetType)]:
          globalHandlers[eventType];
      var target:IEventDispatcher;
      if (targetType)
      {
        target = getRegisteredObject(eventElement.target.@id);
      }
      else
      {
        target = locateDisplayObject(eventElement.target.childAt);
        registerObject(target);
      }
      const bubbles:Boolean = toBoolean(eventElement.bubbles);
      const cancelable:Boolean = toBoolean(eventElement.cancelable);
      const event:Event = pluginData.plugin.toEvent(target,
                                                    eventType,
                                                    bubbles,
                                                    cancelable,
                                                    eventElement);
      pluginData.plugin.beforeDispatch(eventElement, target, event);
      _currentEvent = event;
      try
      {
        target.dispatchEvent(event);
      }
      finally
      {
        _currentEvent = null;
      }
      pluginData.plugin.afterDispatch(eventElement, target, event);
    }
    
    public final function locateDisplayObject(xml:XMLList):DisplayObject
    {
      var displayObject:DisplayObject = stage;
      for each (var childAt:XML in xml)
      {
        displayObject = DisplayObjectContainer(displayObject).
                        getChildAt(childAt.@index);
        /*
        if (displayObject.name != childAt.@name)
        {
          throw new IllegalOperationError();
        }
        */
      }
      return displayObject;
    }
    
    public final function getRegisteredObject(id:uint):IEventDispatcher
    {
      for (var p:* in idsOfObject)
      {
        if (idsOfObject[p] == id)
        {
          return p;
        }
      }
      throw new IllegalOperationError();
    }
    
    public final function get running():Boolean
    {
      return _stage != null;
    }

    public final function stop():void
    {
      if (!running)
      {
        throw new IllegalOperationError();
      }
      const stage:Stage = _stage;
      _stage = null;
      stage.removeEventListener(Event.ENTER_FRAME,
                                enterFrameHandler);
      stage.removeEventListener(Event.EXIT_FRAME,
                                enterFrameHandler);
      for (var p:* in idsOfObject)
      {
        const product:IEventDispatcher = p;
        for each (var pluginHandlers:PluginData in instanceHandlers)
        {
          for each (var eventName:String in pluginHandlers.plugin.eventNames)
          {
            product.removeEventListener(eventName,
                                        pluginHandlers.handler,
                                        true);
            product.removeEventListener(eventName,
                                        pluginHandlers.handler,
                                        false);
          }
        }
      }
      for (var globalEventName:String in globalHandlers)
      {
        const globalPlugin:PluginData = globalHandlers[globalEventName];
        stage.removeEventListener(globalEventName,
                                  globalPlugin.handler,
                                  true);
        stage.removeEventListener(globalEventName,
                                  globalPlugin.handler,
                                  false);
      }
    }
    
    public static const CONNECTION_NAME_PREFIX:String =
        "app#com.netease.recording.server:";

    private const server:LocalConnection = new LocalConnection();
    
    private var connectionName:String

    private var replayName:String

    public function BaseReplayManager(connectionName:String, replayName:String)
    {
      this.connectionName = connectionName;
      this.replayName = replayName;
    }
    
    private var eventIndex:uint = 0;
    
    private var eventList:XMLList;
    
    private function replayLoaded(eventList:XMLList):void
    {
      if (running)
      {
        if (eventList == null)
        {
          dispatchEvent(new ReplayEvent(ReplayEvent.NOT_FOUND));
          stop();
        }
        else
        {
          stage.addEventListener(Event.ENTER_FRAME,
                                 enterFrameHandler,
                                 false,
                                 EventPriority.MANAGER_CAPTURE);
          stage.addEventListener(Event.EXIT_FRAME,
                                 enterFrameHandler,
                                 false,
                                 EventPriority.MANAGER_CAPTURE);
          this.eventList = eventList;
        }
      }
    }

    public final function start(stage:Stage):void
    {
      if (running || !stage)
      {
        throw new IllegalOperationError();
      }
      _stage = stage;
      const resultConnectionName:String = "replayData_" + Math.random()
      server.allowDomain("app#com.netease.recording.server");
      server.connect(resultConnectionName);
      server.client = new ReplayDataClient(replayLoaded);
      server.send(CONNECTION_NAME_PREFIX + connectionName,
                  "getReplay",
                  replayName,
                  server.domain + ':' + resultConnectionName);
      for each (var globalPlugin:PluginData in globalHandlers)
      {
        for each (var eventName:String in globalPlugin.plugin.eventNames)
        {
          stage.addEventListener(eventName,
                                 globalPlugin.handler,
                                 true,
                                 EventPriority.MANAGER_CAPTURE);
          stage.addEventListener(eventName,
                                 globalPlugin.handler,
                                 false,
                                 EventPriority.MANAGER_CAPTURE);
        }
      }
    }
    
    private var _locked:Boolean;
    
    replay_internal final function get locked():Boolean
    {
      return _locked;
    }
    
    private function lock():void
    {
      if (_locked) {
        throw new IllegalOperationError();
      }
      _locked = true;
    }
    
    private function unlock():void
    {
      if (!_locked) {
        throw new IllegalOperationError();
      }
      _locked = false;
    }
    
    private var _currentEvent:Event = null;
    
    replay_internal final function get currentEvent():Event
    {
      return _currentEvent;
    }
  }
}
import com.netease.recording.client.BaseReplayManager;
import com.netease.recording.client.IReplayPlugin;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;
namespace replay_internal;
final class ReplayDataClient
{
  private var onComplete:Function

  private var data:ByteArray = new ByteArray();
  
  public function ReplayDataClient(onComplete:Function)
  {
    this.onComplete = onComplete;
  }
  
  public function notFound():void
  {
    onComplete(null);
  }
  
  public function replayData(buffer:ByteArray):void
  {
    data.writeBytes(buffer);
  }
  
  public function replayEnd():void
  {
    data.position = 0;
    onComplete(XML(data.readUTFBytes(data.length)).children());
  }

}
final class PluginData
{
  public var manager:BaseReplayManager;

  public var plugin:IReplayPlugin;

  public function PluginData(manager:BaseReplayManager, plugin:IReplayPlugin)
  {
    this.manager = manager;
    this.plugin = plugin;
  }
  
  public function handler(event:Event):void
  {
    if (event.eventPhase == EventPhase.BUBBLING_PHASE)
    {
      return;
    }
    if (manager.replay_internal::locked)
    {
      // 由代码触发的事件，应该无视
      return;
    }
    if (manager.replay_internal::currentEvent != event)
    {
      event.stopImmediatePropagation();
      event.preventDefault();
      return;
    }
  }

}
