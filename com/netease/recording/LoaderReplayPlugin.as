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
  import flash.errors.*;
  import flash.events.*;
  import flash.net.URLRequestHeader;
  import flash.system.*;

  public class LoaderReplayPlugin extends ReplayPlugin implements IReplayPlugin
  {
    public function LoaderReplayPlugin(manager:BaseReplayManager)
    {
      super(manager);
    }
    
    public function get targetType():Class
    {
      return ILoader;
    }
    
    public function newInstance(...args):*
    {
      return new ReplayLoader();
    }
    
    public function get eventNames():Array
    {
      return [Event.COMPLETE,
              HTTPStatusEvent.HTTP_STATUS,
              Event.INIT,
              IOErrorEvent.IO_ERROR,
              ProgressEvent.PROGRESS];
    }
    
    private function xmlToHeaders(xmlList:XMLList):Array
    {
      const result:Array = []
      for (var i:uint = 0; i < xmlList.length(); i++)
      {
        const xml:XML = xmlList[i];
        result.push(new URLRequestHeader(xml.@name, xml.@value));
      }
      return result;
    }
    
    public function toEvent(target:IEventDispatcher,
                            type:String,
                            bubbles:Boolean,
                            cancelable:Boolean,
                            xml:XML):Event
    {
      switch (type)
      {
        case Event.COMPLETE:
        case Event.INIT:
        {
          return new Event(type, bubbles, cancelable);
        }
        case IOErrorEvent.IO_ERROR:
        {
          if (Capabilities.playerType == "Desktop")
          {
            return new (IOErrorEvent)(type,
                                      bubbles,
                                      cancelable,
                                      xml.text,
                                      xml.errorID);
          }
          else
          {
            return new IOErrorEvent(type, bubbles, cancelable, xml.text);
          }
        }
        case HTTPStatusEvent.HTTP_STATUS:
        {
          if (Capabilities.playerType == "Desktop")
          {
            return new (HTTPStatusEvent)(type,
                                         bubbles,
                                         cancelable,
                                         xml.status,
                                         xml.responseURL,
                                         xmlToHeaders(xml.URLRequestHeader));
          }
          else
          {
            return new HTTPStatusEvent(type,
                                       bubbles,
                                       cancelable,
                                       xml.status);
          }
        }
        case ProgressEvent.PROGRESS:
        {
          return new ProgressEvent(type,
                                   bubbles,
                                   cancelable,
                                   xml.bytesLoaded,
                                   xml.bytesTotal);
        }
        default:
        {
          throw new ArgumentError();
        }
      }
    }
    
  }
}
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.display.Loader;
import com.netease.recording.BaseReplayManager;
import flash.display.LoaderInfo;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.EventDispatcher;
import com.netease.recording.ILoader;
import com.netease.recording.ILoaderInfo;

final class LoaderDisplay extends Loader
{
  private var replayLoader:ReplayLoader
  function LoaderDisplay(replayLoader:ReplayLoader)
  {
    this.replayLoader = replayLoader;
  }
}

final class ReplayLoader extends EventDispatcher implements ILoader, ILoaderInfo
{
  private const _loader:LoaderDisplay = new LoaderDisplay(ReplayLoader(this));
    
  public function asDisplayObject():DisplayObjectContainer
  {
    return _loader;
  }
  
  public function get content():DisplayObject
  {
    return _loader.content;
  }
    
  public function get contentLoaderInfo():ILoaderInfo
  {
    return this;
  }
  
  public function close():void
  {
    _loader.close();
  }
  
  public function load(request:URLRequest, context:LoaderContext = null):void
  {
    _loader.load(request, context);
  }
  
  public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
  {
    _loader.loadBytes(bytes, context);
  }
  
  public function unload():void
  {
    _loader.unload();
  }
  
  public function unloadAndStop(gc:Boolean = true):void
  {
    _loader.unloadAndStop(gc);
  }
  
  public function get actionScriptVersion():uint
  {
    return loader.contentLoaderInfo.actionScriptVersion;
  }
    
  public function get applicationDomain():ApplicationDomain
  {
    return loader.contentLoaderInfo.applicationDomain;
  }
    
  public function get bytesLoaded():uint
  {
    return loader.contentLoaderInfo.bytesLoaded;
  }
    
  public function get bytesTotal():uint
  {
    return loader.contentLoaderInfo.bytesTotal;
  }
    
  public function get childAllowsParent():Boolean
  {
    return loader.contentLoaderInfo.childAllowsParent;
  }
    
  public function get contentType():String
  {
    return loader.contentLoaderInfo.contentType;
  }
    
  public function get frameRate():Number
  {
    return loader.contentLoaderInfo.frameRate;
  }
    
  public function get height():int
  {
    return loader.contentLoaderInfo.height;
  }
    
  public function get loader():ILoader
  {
    return this;
  }
    
  public function get loaderURL():String
  {
    return loader.contentLoaderInfo.loaderURL;
  }
    
  public function get parameters():Object
  {
    return loader.contentLoaderInfo.parameters;
  }
    
  public function get parentAllowsChild():Boolean
  {
    return loader.contentLoaderInfo.parentAllowsChild;
  }
    
  public function get sameDomain():Boolean
  {
    return loader.contentLoaderInfo.sameDomain;
  }
    
  public function get sharedEvents():EventDispatcher
  {
    return loader.contentLoaderInfo.sharedEvents;
  }

  public function get swfVersion():uint
  {
    return loader.contentLoaderInfo.swfVersion;
  }
    
  public function get url():String
  {
    return loader.contentLoaderInfo.url;
  }
    
  public function get width():int
  {
    return loader.contentLoaderInfo.width;
  }
  
}
