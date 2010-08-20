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
  import flash.net.URLRequest;
  import flash.system.LoaderContext;
  import flash.utils.ByteArray;
  public interface ILoader
  {
    function get content():DisplayObject;
    
    function get contentLoaderInfo():ILoaderInfo;
    
    function close():void;
    
    function load(request:URLRequest, context:LoaderContext = null):void;
    
    function loadBytes(bytes:ByteArray, context:LoaderContext = null):void;
    
    function unload():void;
    
    function unloadAndStop(gc:Boolean = true):void;
    
    function asDisplayObject():DisplayObjectContainer;
  }
}