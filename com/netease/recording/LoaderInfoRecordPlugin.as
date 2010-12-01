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
  
  public final class LoaderInfoRecordPlugin extends RecordPlugin
                                        implements IRecordPlugin
  {
    public function LoaderInfoRecordPlugin(manager:RecordManager)
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