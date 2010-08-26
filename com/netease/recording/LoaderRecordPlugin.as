// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.Loader;
  import flash.display.LoaderInfo;
  import flash.errors.IllegalOperationError;
  import flash.events.*;
  import flash.net.URLRequestHeader;
  import flash.system.Capabilities;
  
  public final class LoaderRecordPlugin extends RecordPlugin
                                        implements IRecordPlugin
  {
    public function LoaderRecordPlugin(manager:RecordManager)
    {
      super(manager);
    }

    public function get targetType():Class
    {
      return ILoader;
    }

    public var simulateDownloadRate:Number = NaN;
    
    public function newInstance(...args):*
    {
      return new RecordLoader(simulateDownloadRate);
    }
    
    public function get eventNames():Array
    {
      return [Event.COMPLETE,
              HTTPStatusEvent.HTTP_STATUS,
              Event.INIT,
              IOErrorEvent.IO_ERROR,
              ProgressEvent.PROGRESS];
    }
    
    private function headersToXML(headers:Array):XMLList
    {
      const result:XMLList = new XMLList();
      for (var i:uint = 0; i < headers.length; i++)
      {
        const header:URLRequestHeader = headers[i];
        result[result.length()] =
            <URLRequestHeader name={header.name} value={header.value}/>;
      }
      return result;
    }
    
    public function toXMLList(event:Event):XMLList
    {
      switch (event.type)
      {
        case Event.COMPLETE:
        case Event.INIT:
        {
          return XMLList(<!-- No addition properties -->);
        }
        case IOErrorEvent.IO_ERROR:
        {
          return toXML("text", IOErrorEvent(event).text) +
                 (Capabilities.playerType == "Desktop" ?
                     toXML("errorID", event["errorID"]) :
                     <!-- No AIR properties -->);
        }
        case HTTPStatusEvent.HTTP_STATUS:
        {
          return toXML("status", HTTPStatusEvent(event).status) +
                 (Capabilities.playerType == "Desktop" ?
                     toXML("responseURL", event["responseURL"]) +
                     headersToXML(event["responseHeaders"]) :
                     <!-- No AIR properties -->);
        }
        case ProgressEvent.PROGRESS:
        {
          const progressEvent:ProgressEvent = ProgressEvent(event);
          return toXML("bytesLoaded", progressEvent.bytesLoaded) +
                 toXML("bytesTotal", progressEvent.bytesTotal);
        }
        default:
        {
          throw new ArgumentError();
        }
      }
    }
    
  }
}
import flash.display.LoaderInfo;
import flash.display.Loader;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.*;
import com.netease.recording.BaseRecordManager;
import flash.utils.Timer;
import flash.errors.IllegalOperationError;
import com.netease.recording.ILoader;
import com.netease.recording.ILoaderInfo;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;

final class LoaderDisplay extends Loader
{
  private var recordLoader:RecordLoader
  function LoaderDisplay(recordLoader:RecordLoader)
  {
    this.recordLoader = recordLoader;
  }
}

final class RecordLoader extends EventDispatcher implements ILoader, ILoaderInfo
{
  private const _loaderInfo:LoaderInfo =
      new LoaderDisplay(RecordLoader(this)).contentLoaderInfo;
  
  private var simulateDownloadRate:Number;
  
  private function contentLoaderInfo_unloadHandler(event:Event):void
  {
    if (simulateCompleteTimer)
    {
      simulateCompleteTimer.stop();
      simulateCompleteTimer = null;
    }
    dispatchDeferredEvents();
    dispatchEvent(event);
  }

  private function contentLoaderInfo_ioErrorHandler(event:IOErrorEvent):void
  {
    if (simulateCompleteTimer)
    {
      throw new IllegalOperationError();
    }
    dispatchDeferredEvents();
    dispatchEvent(event);
  }
  
  private var simulateCompleteTimer:Timer;
  
  private function simulateCompleteTimer_timerCompleteHandler(
      event:TimerEvent):void
  {
    dispatchDeferredEvents();
  }
  
  private function contentLoaderInfo_completeHandler(event:Event):void
  {
    if (isNaN(simulateDownloadRate))
    {
      dispatchDeferredEvents();
      dispatchEvent(event);
    }
    else
    {
      deferredEvents.push(event);
      simulateCompleteTimer = new Timer(
          1000 * bytesTotal / simulateDownloadRate,
          1);
      simulateCompleteTimer.addEventListener(
          TimerEvent.TIMER_COMPLETE,
          simulateCompleteTimer_timerCompleteHandler);
      simulateCompleteTimer.start();
    }
  }
  
  [ArrayElementType("flash.events.Event")]
  private var deferredEvents:Array = [];
  
  private function dispatchDeferredEvents():void
  {
    const a:Array = deferredEvents;
    deferredEvents = [];
    for (var i:uint = 0; i < a.length; i++)
    {
      const event:Event = a[i];
      dispatchEvent(event);
    }
  }
  
  private function defer(event:Event):void
  {
    deferredEvents.push(event);
  }
  
  public function RecordLoader(simulateDownloadRate:Number)
  {
    this.simulateDownloadRate = simulateDownloadRate;
    if (isNaN(simulateDownloadRate))
    {
      _loaderInfo.addEventListener(
          Event.COMPLETE,
          dispatchEvent);
      _loaderInfo.addEventListener(
          HTTPStatusEvent.HTTP_STATUS,
          dispatchEvent);
      _loaderInfo.addEventListener(
          Event.INIT,
          dispatchEvent);
      _loaderInfo.addEventListener(
          ProgressEvent.PROGRESS,
          dispatchEvent);
      _loaderInfo.addEventListener(
          IOErrorEvent.IO_ERROR,
          dispatchEvent);
      _loaderInfo.addEventListener(
          Event.UNLOAD,
          dispatchEvent);
    }
    else
    {
      _loaderInfo.addEventListener(
          Event.COMPLETE,
          contentLoaderInfo_completeHandler);
      _loaderInfo.addEventListener(
          HTTPStatusEvent.HTTP_STATUS,
          defer);
      _loaderInfo.addEventListener(
          Event.INIT,
          defer);
      _loaderInfo.addEventListener(
          ProgressEvent.PROGRESS,
          defer);
      _loaderInfo.addEventListener(
          IOErrorEvent.IO_ERROR,
          contentLoaderInfo_ioErrorHandler);
      _loaderInfo.addEventListener(
          Event.UNLOAD,
          contentLoaderInfo_unloadHandler);
    }
    _loaderInfo.addEventListener(
        Event.OPEN,
        dispatchEvent);
  }

  public function asDisplayObject():DisplayObjectContainer
  {
    return _loaderInfo.loader;
  }
  
  public function get content():DisplayObject
  {
    return _loaderInfo.content;
  }
    
  public function get contentLoaderInfo():ILoaderInfo
  {
    return this;
  }
  
  public function close():void
  {
    _loaderInfo.loader.close();
  }
  
  public function load(request:URLRequest, context:LoaderContext = null):void
  {
    _loaderInfo.loader.load(request, context);
  }
  
  public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
  {
    _loaderInfo.loader.loadBytes(bytes, context);
  }
  
  public function unload():void
  {
    _loaderInfo.loader.unload();
  }
  
  public function unloadAndStop(gc:Boolean = true):void
  {
    _loaderInfo.loader.unloadAndStop(gc);
  }
  
  public function get actionScriptVersion():uint
  {
    return _loaderInfo.actionScriptVersion;
  }
    
  public function get applicationDomain():ApplicationDomain
  {
    return _loaderInfo.applicationDomain;
  }
    
  public function get bytesLoaded():uint
  {
    return _loaderInfo.bytesLoaded;
  }
    
  public function get bytesTotal():uint
  {
    return _loaderInfo.bytesTotal;
  }
    
  public function get childAllowsParent():Boolean
  {
    return _loaderInfo.childAllowsParent;
  }
    
  public function get contentType():String
  {
    return _loaderInfo.contentType;
  }
    
  public function get frameRate():Number
  {
    return _loaderInfo.frameRate;
  }
    
  public function get height():int
  {
    return _loaderInfo.height;
  }
    
  public function get loader():ILoader
  {
    return this;
  }
    
  public function get loaderURL():String
  {
    return _loaderInfo.loaderURL;
  }
    
  public function get parameters():Object
  {
    return _loaderInfo.parameters;
  }
    
  public function get parentAllowsChild():Boolean
  {
    return _loaderInfo.parentAllowsChild;
  }
    
  public function get sameDomain():Boolean
  {
    return _loaderInfo.sameDomain;
  }
    
  public function get sharedEvents():EventDispatcher
  {
    return _loaderInfo.sharedEvents;
  }

  public function get swfVersion():uint
  {
    return _loaderInfo.swfVersion;
  }
    
  public function get url():String
  {
    return _loaderInfo.url;
  }
    
  public function get width():int
  {
    return _loaderInfo.width;
  }

}