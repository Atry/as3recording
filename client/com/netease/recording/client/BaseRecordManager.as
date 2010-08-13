// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording.client
{
  
  import flash.display.DisplayObject;
  import flash.display.Stage;
  import flash.errors.IllegalOperationError;
  import flash.events.*;
  import flash.net.LocalConnection;
  import flash.utils.Dictionary;
  import flash.utils.getQualifiedClassName;
  
  [Event(type="flash.events.IOErrorEvent", name="ioError")]
  public class BaseRecordManager extends EventDispatcher implements IRecorder
  {
    private var seed:uint = 0;

    private const idsOfObject:Dictionary = new Dictionary(true);
    
    public function getRegisterObjectId(object:Object):uint
    {
      if (!(object in idsOfObject))
      {
        throw new ArgumentError();
      }
      return idsOfObject[object];
    }

    private function registerObject(object:Object):void
    {
      idsOfObject[object] = seed++;
    }
    
    private var globalHandlers:Vector.<PluginData> =
        new Vector.<PluginData>();

    private var instanceHandlers:Dictionary = new Dictionary();

    public final function addPlugin(plugin:IRecordPlugin):void {
      if (!plugin.targetType)
      {
        globalHandlers.push(new PluginData(this, plugin));
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
        const pluginData:PluginData = instanceHandlers[type];
        for each (var eventName:String in pluginData.plugin.eventNames)
        {
          product.addEventListener(eventName,
                                   pluginData.handler,
                                   true,
                                   EventPriority.MANAGER_CAPTURE);
          product.addEventListener(eventName,
                                   pluginData.handler,
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

    public static const CONNECTION_NAME_PREFIX:String =
        "app#com.netease.recording.server:";

    private const connection:LocalConnection = new LocalConnection();

    private const recordName:String = (function():String
    {
      const date:Date = new Date();
      return "" +
          uint(date.fullYear / 1000) + uint(date.fullYear / 100 % 10) + 
          uint(date.fullYear / 10 % 10) + uint(date.fullYear % 10) + '-' +
          uint((date.month + 1) / 10) + uint((date.month + 1) % 10) + '-' +
          uint(date.date / 10) + uint(date.date % 10) + "_" +
          uint(date.hours / 10) + uint(date.hours % 10) + '.' +
          uint(date.minutes / 10) + uint(date.minutes % 10) + '.' +
          uint(date.seconds / 10) + uint(date.seconds % 10) + '.' +
          uint(date.milliseconds / 100 % 10) + 
          uint(date.milliseconds / 10 % 10) +
          uint(date.milliseconds % 10) + "_" +
          uint(Math.random() * uint.MAX_VALUE).toString(16) + ".as3replay";
    })();

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
      if (_locked) {
        throw new IllegalOperationError();
      }
      _locked = true;
    }
    
    record_internal final function unlock():void
    {
      if (!_locked) {
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
        // 由代码触发的事件，应该无视
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

    public final function stop():void
    {
      if (!running)
      {
        throw new IllegalOperationError();
      }
      const stage:Stage = _stage;
      _stage = null;
      connection.close();
      connection.send(CONNECTION_NAME_PREFIX + connectionName,
                  "stopRecord",
                  recordName);
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
      for each (var globalPlugin:PluginData in globalHandlers)
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
    
    private var connectionName:String;
    
    public function BaseRecordManager(connectionName:String)
    {
      this.connectionName = connectionName;
    }
    
    public final function get running():Boolean
    {
      return _stage != null;
    }
    private function connection_securityErrorHandler(
        event:SecurityErrorEvent):void
    {
      // Ignore.
    }
    
    private function connection_statusHandler(event:StatusEvent):void
    {
      switch (event.level)
      {
        case "error":
        {
          if (running)
          {
            dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
            stop();
          }
          break;
        }
        case "status":
        {
          break;
        }
        case "warning":
        default:
        {
          throw new IllegalOperationError();
        }
      }
    }
    
    public final function start(stage:Stage):void
    {
      if (!stage)
      {
        throw new ArgumentError();
      }
      if (running)
      {
        throw new IllegalOperationError();
      }
      _stage = stage;
      connection.connect("_" + recordName);
      connection.addEventListener(StatusEvent.STATUS, connection_statusHandler);
      connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                                  connection_securityErrorHandler);
      connection.send(CONNECTION_NAME_PREFIX + connectionName,
                      "startRecord",
                      recordName);
      stage.addEventListener(Event.ENTER_FRAME,
                             enterFrameHandler,
                             false,
                             EventPriority.MANAGER_CAPTURE);
      stage.addEventListener(Event.EXIT_FRAME,
                             enterFrameHandler,
                             false,
                             EventPriority.MANAGER_CAPTURE);
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
    
    public final function getDisplayPath(displayObject:DisplayObject):XMLList
    {
      if (displayObject.stage != _stage)
      {
        return null;
      }
      const a:Vector.<XML> = new Vector.<XML>();
      while (displayObject != _stage)
      {
        a.push(<childAt name={displayObject.name}
            index={displayObject.parent.getChildIndex(displayObject)}/>);
        displayObject = displayObject.parent;
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

    record_internal final function record(plugin:IRecordPlugin,
                                          event:Event):void
    {
      if (frameChanged)
      {
        frameChanged = false;
        connection.send(CONNECTION_NAME_PREFIX + connectionName,
                        "record",
                        recordName,
                        <frame n={frameCount} phase={framePhase}/>);
      }
      if (plugin.targetType == null)
      {
        registerObject(event.target);
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
      connection.send(CONNECTION_NAME_PREFIX + connectionName,
                      "record",
                      recordName,
                      eventXML);
    }

  }
}
import com.netease.recording.client.*;
import flash.errors.*;
import flash.events.*;
namespace record_internal;
final class PluginData
{
  public var manager:BaseRecordManager;

  public var plugin:IRecordPlugin;

  public function PluginData(manager:BaseRecordManager, plugin:IRecordPlugin)
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
