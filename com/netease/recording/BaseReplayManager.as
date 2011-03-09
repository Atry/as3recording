// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{

  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Stage;
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.EventPhase;
  import flash.events.IEventDispatcher;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.utils.ByteArray;
  import flash.utils.Dictionary;
  import flash.utils.getDefinitionByName;
  
  [Event(type="com.netease.recording.ReplayEvent", name="notFound")]
  [Event(type="com.netease.recording.ReplayEvent", name="complete")]
  public class BaseReplayManager extends EventDispatcher implements IRecordingManager
  {
    private var seed:uint = 0;

    private const idsOfObject:Dictionary = new Dictionary(true);
    
    [ArrayElementType("uint")]
    private var referenceCount:Array;

    private const objectsByID:Array = [];

    private var globalHandlers:Object = {}

    private var instanceHandlers:Dictionary = new Dictionary();

    public final function addPlugin(plugin:IReplayPlugin):void {
      if (!plugin.targetType)
      {
        const handlers:ReplayPluginData = new ReplayPluginData(this, plugin);
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
        instanceHandlers[plugin.targetType] = new ReplayPluginData(this, plugin);
      }
    }
    
    private function addObject(object:*):uint
    {
      const id:uint = seed++;
      if (!referenceCount || referenceCount[id])
      {
        objectsByID[id] = object;
      }
      return id;
    }
     
    replay_internal final function registerObject(pluginData:ReplayPluginData,
                                                  object:*):void
    {
      const eventDispatcher:IEventDispatcher = object as IEventDispatcher;
      if (eventDispatcher)
      {
        for each (var eventName:String in pluginData.plugin.eventNames)
        {
          eventDispatcher.addEventListener(eventName,
                                           pluginData.handler,
                                           true,
                                           _eventPriority);
          eventDispatcher.addEventListener(eventName,
                                           pluginData.handler,
                                           false,
                                           _eventPriority);
        }
      }
      idsOfObject[object] = addObject(object);
    }
    
    public final function registerObject(type:Class, object:*):void
    {
      const pluginData:ReplayPluginData = instanceHandlers[type];
      if (running)
      {
        replay_internal::registerObject(pluginData, object);
      }
    }
    
    public final function newInstance(type:Class, ...args):*
    {
      const pluginData:ReplayPluginData = instanceHandlers[type];
      const product:* = pluginData.plugin.newInstance.apply(null, args);
      if (running)
      {
        replay_internal::registerObject(pluginData, product);
      }
      return product;
    }

    private var _stage:Stage;
    
    public final function get stage():Stage
    {
      return _stage;
    }
    
    public final function random():Number
    {
      if (running)
      {
        const randomElement:XML = eventList[eventIndex];
        if (randomElement.name() != "random")
        {
          throw new IllegalOperationError();
        }
        /*if (randomElement.text() == "4042158356951990300")
        {
          trace(randomElement);
        }*/
        eventIndex++;
        return Number(randomElement.text().toString()) / 0x10000000000000000;
      }
      else
      {
        return Math.random();
      }
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
        }
        event.stopImmediatePropagation();
        if (!IEventDispatcher(event.target).dispatchEvent(event))
        {
          event.preventDefault();
        }
        for (;;)
        {
          if (eventList.length() <= eventIndex)
          {
            stop();
            eventList = null;
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
      const targetTypeName:String = eventElement.@targetType;
      const targetType:Class =
          targetTypeName ?
          Class(getDefinitionByName(targetTypeName)) :
          null;
      const pluginData:ReplayPluginData =
          targetType ?
          instanceHandlers[targetType]:
          globalHandlers[eventType];
      var target:IEventDispatcher;
      if (targetType)
      {
        target = releaseRegisteredObject(eventElement.target.@id);
        if (!(target is targetType))
        {
          throw new IllegalOperationError();
        }
      }
      else
      {
        try
        {
          target = locateDisplayObject(eventElement.target.childAt);
        }
        catch(e:RangeError)
        {
          trace("Warning: Target not found and event was ignored.",
            eventElement.toXMLString());
          return;
        }
      }
      const bubbles:Boolean = toBoolean(eventElement.bubbles);
      const cancelable:Boolean = toBoolean(eventElement.cancelable);
      const event:Event = pluginData.plugin.toEvent(target,
                                                    eventType,
                                                    bubbles,
                                                    cancelable,
                                                    eventElement);
      pluginData.plugin.beforeDispatch(eventElement, target, event);
      target.dispatchEvent(event);
      pluginData.plugin.afterDispatch(eventElement, target, event);
    }
    
    public final function locateDisplayObject(xml:XMLList):DisplayObject
    {
      var displayObject:DisplayObject = stage;
      for each (var childAt:XML in xml)
      {
        displayObject = ContainerUtils.getChildAt(
          DisplayObjectContainer(displayObject), childAt.@index);
      }
      return displayObject;
    }
    
    public final function releaseRegisteredObject(id:uint):*
    {
      const result:* = objectsByID[id];
      if (referenceCount)
      {
        const currentCount:uint = referenceCount[id];
        currentCount--;
        if (currentCount == 0)
        {
          do
          {
            delete referenceCount[id];
          }
          while (id in referenceCount);
          do
          {
            delete objectsByID[id];
          }
          while (id in objectsByID);
        }
        else
        {
          referenceCount[id] = currentCount;
        }
      }
      return result;
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
      if (urlLoader)
      {
        urlLoader.close();
        urlLoader = null;
      }
      const stage:Stage = _stage;
      _stage = null;
      referenceCount = null;
      stage.removeEventListener(Event.ENTER_FRAME,
                                enterFrameHandler);
      stage.removeEventListener(Event.EXIT_FRAME,
                                enterFrameHandler);
      for (var p:* in idsOfObject)
      {
        const product:IEventDispatcher = p;
        for each (var pluginHandlers:ReplayPluginData in instanceHandlers)
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
        const globalPlugin:ReplayPluginData = globalHandlers[globalEventName];
        stage.removeEventListener(globalEventName,
                                  globalPlugin.handler,
                                  true);
        stage.removeEventListener(globalEventName,
                                  globalPlugin.handler,
                                  false);
      }
    }
    
    private var urlRequest:URLRequest;

    public function BaseReplayManager(urlRequest:URLRequest)
    {
      this.urlRequest = urlRequest;
    }
    
    private var eventIndex:uint = 0;
    
    private var eventList:XMLList;
    
    private function replayLoaded(eventList:XMLList):void
    {
      const ids:XMLList = eventList..@id;
      referenceCount = [];
      for each (var id:uint in ids)
      {
        referenceCount[id] = uint(referenceCount[id]) + 1;
      }
      if (running)
      {
        if (eventList == null)
        {
          stop();
          dispatchEvent(new ReplayEvent(ReplayEvent.NOT_FOUND));
        }
        else
        {
          stage.addEventListener(Event.ENTER_FRAME,
                                 enterFrameHandler,
                                 false,
                                 _eventPriority);
          stage.addEventListener(Event.EXIT_FRAME,
                                 enterFrameHandler,
                                 false,
                                 _eventPriority);
          this.eventList = eventList;
        }
      }
    }
    
    private var urlLoader:URLLoader;
    
    private function urlLoader_completeHandler(event:Event):void
    {
      if (urlLoader == event.currentTarget)
      {
        const data:String = urlLoader.data;
        if (data.search(/<\/as3replay>\s*$/) == -1)
        {
          replayLoaded(XML(data + "</as3replay>").children());
        }
        else
        {
          replayLoaded(XML(data).children());
        }
        urlLoader.close();
        urlLoader = null;
      }
    }
    
    private var _eventPriority:int;
    
    public final function get eventPriority():int
    {
      return _eventPriority;
    }

    public final function start(stage:Stage, eventPriority:int = 10000):void
    {
      if (running || !stage)
      {
        throw new IllegalOperationError();
      }
      _eventPriority = eventPriority;
      _stage = stage;
      urlLoader = new URLLoader();
      urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler);
      urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
      urlLoader.load(urlRequest);
      for each (var globalPlugin:ReplayPluginData in globalHandlers)
      {
        for each (var eventName:String in globalPlugin.plugin.eventNames)
        {
          stage.addEventListener(eventName,
                                 globalPlugin.handler,
                                 true,
                                 eventPriority);
          stage.addEventListener(eventName,
                                 globalPlugin.handler,
                                 false,
                                 eventPriority);
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
      if (_locked)
      {
        throw new IllegalOperationError();
      }
      _locked = true;
    }
    
    private function unlock():void
    {
      if (!_locked)
      {
        throw new IllegalOperationError();
      }
      _locked = false;
    }
    
  }
}
import com.netease.recording.BaseReplayManager;
import com.netease.recording.IReplayPlugin;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;
namespace replay_internal;
final class ReplayPluginData
{
  public var manager:BaseReplayManager;

  public var plugin:IReplayPlugin;

  public function ReplayPluginData(manager:BaseReplayManager, plugin:IReplayPlugin)
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
    if (!manager.replay_internal::locked)
    {
      event.stopImmediatePropagation();
      event.preventDefault();
      return;
    }
  }

}
