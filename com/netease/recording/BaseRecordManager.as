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
  import flash.events.*;
  import flash.net.Socket;
  import flash.net.URLRequestHeader;
  import flash.system.Capabilities;
  import flash.utils.ByteArray;
  import flash.utils.Dictionary;
  import flash.utils.Endian;
  import flash.utils.IDataOutput;
  import flash.utils.getQualifiedClassName;
  
  public class BaseRecordManager implements IRecordingManager
  {
    public var writeFunction:Function;
    
    private var seed:uint = 0;

    private const idsOfObject:Dictionary = new Dictionary(true);
    
    public function getRegisterObjectID(object:Object):uint
    {
      if (!(object in idsOfObject))
      {
        throw new ArgumentError();
      }
      return idsOfObject[object];
    }
    
    private var globalHandlers:Vector.<RecordPluginData> =
        new Vector.<RecordPluginData>();

    private var instanceHandlers:Dictionary = new Dictionary();

    public final function addPlugin(plugin:IRecordPlugin):void {
      if (!plugin.targetType)
      {
        globalHandlers.push(new RecordPluginData(this, plugin));
      }
      else
      {
        if (plugin.targetType in instanceHandlers)
        {
          throw new ArgumentError();
        }
        instanceHandlers[plugin.targetType] = new RecordPluginData(this, plugin);
      }
    }
    
    record_internal final function registerObject(pluginData:RecordPluginData,
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
      idsOfObject[object] = seed++;
    }
    
    public final function registerObject(type:Class, object:*):void
    {
      const pluginData:RecordPluginData = instanceHandlers[type];
      if (running)
      {
        record_internal::registerObject(pluginData, object);
      }
    }
    
    public final function newInstance(type:Class, ...args):*
    {
      const pluginData:RecordPluginData = instanceHandlers[type];
      const product:* = pluginData.plugin.newInstance.apply(null, args);
      if (running)
      {
        record_internal::registerObject(pluginData, product);
      }
      return product;
    }

    private var _stage:Stage;
    
    public final function get stage():Stage
    {
      return _stage;
    }
    
    private var frameChanged:Boolean = true;

    private var frameCount:uint = 1;

    private var framePhase:String;
    
    private var _locked:Boolean;
    
    record_internal final function get locked():Boolean
    {
      return _locked;
    }
    
    record_internal final function lock():void
    {
      if (_locked)
      {
        throw new IllegalOperationError();
      }
      _locked = true;
    }
    
    record_internal final function unlock():void
    {
      if (!_locked)
      {
        throw new IllegalOperationError();
      }
      _locked = false;
    }

    private function enterFrameHandler(event:Event):void
    {
      if (event.eventPhase != EventPhase.AT_TARGET)
      {
        throw new IllegalOperationError();
      }
      if (record_internal::locked)
      {
        // This event is triggered by user code, so we ignore it.
        return;
      }
      record_internal::lock();
      try
      {
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
      }
      finally
      {
        record_internal::unlock();
      }
    }

    private static const FOOTER:ByteArray = new ByteArray();
    FOOTER.writeUTFBytes("</as3replay>\n");
    
    
    public final function stop():void
    {
      if (!running)
      {
        throw new IllegalOperationError();
      }
      const stage:Stage = _stage;
      _stage = null;
      writeFunction(FOOTER);
      stage.removeEventListener(Event.ENTER_FRAME,
                                enterFrameHandler);
      stage.removeEventListener(Event.EXIT_FRAME,
                                enterFrameHandler);
      for (var p:* in idsOfObject)
      {
        const product:IEventDispatcher = p;
        for each (var pluginHandlers:RecordPluginData in instanceHandlers)
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
      for each (var globalPlugin:RecordPluginData in globalHandlers)
      {
        for each (var globalEventName:String in globalPlugin.plugin.eventNames)
        {
          stage.removeEventListener(globalEventName,
                                    globalPlugin.handler,
                                    true);
          stage.removeEventListener(globalEventName,
                                    globalPlugin.handler,
                                    false);
        }
      }
    }
    
    public final function get running():Boolean
    {
      return _stage != null;
    }

    private static const HEADER:ByteArray = new ByteArray();
    HEADER.writeUTFBytes(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?><as3replay>\n\n");

    private var _eventPriority:int;
    
    public final function get eventPriority():int
    {
      return _eventPriority;
    }
    
    public final function start(stage:Stage, eventPriority:int=10000):void
    {
      writeFunction(HEADER);
      if (!stage)
      {
        throw new ArgumentError();
      }
      if (running)
      {
        throw new IllegalOperationError();
      }
      _stage = stage;
      _eventPriority = eventPriority;
      stage.addEventListener(Event.ENTER_FRAME,
        enterFrameHandler,
        false,
        eventPriority);
      stage.addEventListener(Event.EXIT_FRAME,
        enterFrameHandler,
        false,
        eventPriority);
      for each (var globalPlugin:RecordPluginData in globalHandlers)
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
    
    public final function getDisplayPath(displayObject:DisplayObject):XMLList
    {
      if (displayObject.stage != _stage)
      {
        return null;
      }
      const a:Vector.<XML> = new Vector.<XML>();
      while (displayObject != _stage)
      {
        const parent:DisplayObjectContainer = ContainerUtils.getParent(
          displayObject);
        a.push(<childAt
            index={ContainerUtils.getChildIndex(parent, displayObject)}/>);
        displayObject = parent;
      }
      const childList:XMLList = new XMLList();
      var i:uint = a.length;
      while (i != 0)
      {
        i--;
        childList[childList.length()] = a[i];
      }
      return childList;
    }
    
    public final function random():Number
    {
      const result:Number = Math.random();
      if (!running)
      {
        return result;
      }
      const chunkBuffer:ByteArray = new ByteArray();
      if (frameChanged)
      {
        frameChanged = false;
        chunkBuffer.writeUTFBytes(
          <frame n={frameCount} phase={framePhase || Event.EXIT_FRAME}/>.
          toXMLString());
        chunkBuffer.writeUTFBytes("\n");
      }
      chunkBuffer.writeUTFBytes(
        <random>{(result * 0x10000000000000000).toString()}</random>.toXMLString());
      chunkBuffer.writeUTFBytes("\n\n");
      writeFunction(chunkBuffer);
      return result;
    }
    
    private var count:uint = 0;

    record_internal final function record(plugin:IRecordPlugin,
                                          event:Event):void
    {
      const chunkBuffer:ByteArray = new ByteArray();
      if (frameChanged)
      {
        frameChanged = false;
        chunkBuffer.writeUTFBytes(
          <frame n={frameCount} phase={framePhase || Event.EXIT_FRAME}/>.
          toXMLString());
        chunkBuffer.writeUTFBytes("\n");
      }
      const eventXML:XML =
      <{event.type}>
        {plugin.targetType == null ?
            <target>{getDisplayPath(DisplayObject(event.target))}</target> :
            <target id={idsOfObject[event.target]}/>}
        {event.bubbles ?
          <bubbles>{event.bubbles}</bubbles> :
          <!-- <bubbles>{bubbles}</bubbles> -->
        }
        {event.cancelable ?
          <cancelable>{event.cancelable}</cancelable> :
          <!-- <cancelable>{cancelable}</cancelable> -->
        }
        {plugin.toXMLList(event)}
      </{event.type}>;
      if (plugin.targetType)
      {
        eventXML.@targetType = getQualifiedClassName(plugin.targetType);
      }
      chunkBuffer.writeUTFBytes(eventXML.toXMLString());
      chunkBuffer.writeUTFBytes("\n\n");
      writeFunction(chunkBuffer);
    }
  }
}
import com.netease.recording.*;
import flash.errors.*;
import flash.events.*;
namespace record_internal;
final class RecordPluginData
{
  public var manager:BaseRecordManager;

  public var plugin:IRecordPlugin;

  public function RecordPluginData(manager:BaseRecordManager, plugin:IRecordPlugin)
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
    if (manager.record_internal::locked)
    {
      // 由代码触发的事件，不应该记录
      return;
    }
    manager.record_internal::lock();
    try
    {
      manager.record_internal::record(plugin, event);
      event.stopImmediatePropagation();
      
      if (!IEventDispatcher(event.target).dispatchEvent(event))
      {
        event.preventDefault();
      }
    }
    finally
    {
      manager.record_internal::unlock();
    }
  }
}
