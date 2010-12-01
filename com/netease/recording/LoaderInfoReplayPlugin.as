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

  public class LoaderInfoReplayPlugin extends ReplayPlugin implements IReplayPlugin
  {
    public function LoaderInfoReplayPlugin(manager:BaseReplayManager)
    {
      super(manager);
    }
    
    public function get targetType():Class
    {
      return ILoaderInfo;
    }
    
    public function newInstance(...args):*
    {
      throw new IllegalOperationError();
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
