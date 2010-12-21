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
  
  
  /**
   * @copy flash.display.Loader
   */
  public interface ILoader
  {
    /**
     * @copy flash.display.Loader#content
     */
    function get content():DisplayObject;
    
    /**
     * @copy flash.display.Loader#contentLoaderInfo
     */
    function get contentILoaderInfo():ILoaderInfo;
    
    /**
     * @copy flash.display.Loader#close()
     */
    function close():void;
    
    /**
     * @copy flash.display.Loader#load()
     */
    function load(request:URLRequest, context:LoaderContext = null):void;
    
    /**
     * @copy flash.display.Loader#loadBytes()
     */
    function loadBytes(bytes:ByteArray, context:LoaderContext = null):void;
    
    /**
     * @copy flash.display.Loader#unload()
     */
    function unload():void;
    
    /**
     * @copy flash.display.Loader#unloadAndStop()
     */
    function unloadAndStop(gc:Boolean = true):void;
    
    function asDisplayObject():DisplayObjectContainer;
  }
}