// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.ActionScriptVersion;
  import flash.display.SWFVersion;
  import flash.display.LoaderInfo;
  import flash.display.DisplayObject;
  import flash.events.IEventDispatcher;
  import flash.events.EventDispatcher;
  import flash.system.ApplicationDomain;

  public interface ILoaderInfo extends IEventDispatcher
  {
    function get actionScriptVersion():uint;
    
    function get applicationDomain():ApplicationDomain;
    
    function get bytesLoaded():uint;
    
    function get bytesTotal():uint;
    
    function get childAllowsParent():Boolean;
    
    function get content():DisplayObject;
    
    function get contentType():String;
    
    function get frameRate():Number;
    
    function get height():int;
    
    function get loader():ILoader;
    
    function get loaderURL():String;
    
    function get parameters():Object;
    
    function get parentAllowsChild():Boolean;
    
    function get sameDomain():Boolean;
    
    function get sharedEvents():EventDispatcher;
    
    function get swfVersion():uint;
    
    function get url():String;
    
    function get width():int;

  }
}