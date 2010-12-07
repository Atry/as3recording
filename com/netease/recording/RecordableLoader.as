package com.netease.recording
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Loader;
  import flash.display.LoaderInfo;
  import flash.errors.IllegalOperationError;
  import flash.utils.Dictionary;
  
  public class RecordableLoader extends Loader implements ILoader
  {
    private var recordingManager:IRecordingManager;
    
    public function RecordableLoader(recordingManager:IRecordingManager)
    {
      this.recordingManager = recordingManager;
    }
    
    public override function get contentLoaderInfo():LoaderInfo
    {
      throw new IllegalOperationError();
    }
    
    private var recordableLoaderInfo:RecordableLoaderInfo;
    
    private const weakLoaderInfo:Dictionary = new Dictionary(true);
    
    public function get contentILoaderInfo():ILoaderInfo
    {
      var recordableLoaderInfo:RecordableLoaderInfo;
      for (var p:* in weakLoaderInfo)
      {
        recordableLoaderInfo = p;
        break;
      }
      
      if (recordableLoaderInfo)
      {
        if (recordableLoaderInfo.nativeLoaderInfo != super.contentLoaderInfo)
        {
          delete weakLoaderInfo[recordableLoaderInfo];
          recordableLoaderInfo = new RecordableLoaderInfo(
            super.contentLoaderInfo);
          weakLoaderInfo[recordableLoaderInfo] = true;
          recordingManager.registerObject(ILoaderInfo, recordableLoaderInfo);
        }
      }
      else
      {
        if (super.contentLoaderInfo)
        {
          recordableLoaderInfo = new RecordableLoaderInfo(
            super.contentLoaderInfo);
          weakLoaderInfo[recordableLoaderInfo] = true;
          recordingManager.registerObject(ILoaderInfo, recordableLoaderInfo);
        }
      }
      return recordableLoaderInfo;
    }
    
    public function asDisplayObject():DisplayObjectContainer
    {
      return this;
    }
  }
}
import com.netease.recording.ILoader;
import com.netease.recording.ILoaderInfo;

import flash.display.ActionScriptVersion;
import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.SWFVersion;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

final class RecordableLoaderInfo extends EventDispatcher implements ILoaderInfo
{
  
  public var nativeLoaderInfo:LoaderInfo;
  
  
  public function RecordableLoaderInfo(nativeLoaderInfo:LoaderInfo)
  {
    this.nativeLoaderInfo = nativeLoaderInfo;
    nativeLoaderInfo.addEventListener(Event.COMPLETE, dispatchEvent);
    nativeLoaderInfo.addEventListener(Event.OPEN, dispatchEvent);
    nativeLoaderInfo.addEventListener(Event.UNLOAD, dispatchEvent);
    nativeLoaderInfo.addEventListener(Event.INIT, dispatchEvent);
    nativeLoaderInfo.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);
    nativeLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, dispatchEvent);
    nativeLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dispatchEvent);
  }
  
  public function get actionScriptVersion():uint
  {
    return nativeLoaderInfo.actionScriptVersion;
  }
  
  public function get applicationDomain():ApplicationDomain
  {
    return nativeLoaderInfo.applicationDomain;
  }
  
  public function get bytesLoaded():uint
  {
    return nativeLoaderInfo.bytesLoaded;
  }
  
  public function get bytesTotal():uint
  {
    return nativeLoaderInfo.bytesTotal;
  }
  
  public function get childAllowsParent():Boolean
  {
    return nativeLoaderInfo.childAllowsParent;
  }
  
  public function get content():DisplayObject
  {
    return nativeLoaderInfo.content;
  }
  
  public function get contentType():String
  {
    return nativeLoaderInfo.contentType;
  }
  
  public function get frameRate():Number
  {
    return nativeLoaderInfo.frameRate;
  }
  
  public function get height():int
  {
    return nativeLoaderInfo.height;
  }
  
  public function get loader():ILoader
  {
    return ILoader(nativeLoaderInfo.loader);
  }
  
  public function get loaderURL():String
  {
    return nativeLoaderInfo.loaderURL;
  }
  
  public function get parameters():Object
  {
    return nativeLoaderInfo.parameters;
  }
  
  public function get parentAllowsChild():Boolean
  {
    return nativeLoaderInfo.parentAllowsChild;
  }
  
  public function get sameDomain():Boolean
  {
    return nativeLoaderInfo.sameDomain;
  }
  
  public function get sharedEvents():EventDispatcher
  {
    return nativeLoaderInfo.sharedEvents;
  }
  
  public function get swfVersion():uint
  {
    return nativeLoaderInfo.swfVersion;
  }
  
  public function get url():String
  {
    return nativeLoaderInfo.url;
  }
  
  public function get width():int
  {
    return nativeLoaderInfo.width;
  }

}