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
  
  [Event(type="flash.events.Event", name="complete")]
  [Event(type="flash.events.Event", name="open")]
  [Event(type="flash.events.Event", name="unload")]
  [Event(type="flash.events.Event", name="init")]
  [Event(type="flash.events.ProgressEvent", name="progress")]
  [Event(type="flash.events.HTTPStatusEvent", name="httpStatus")]
  [Event(type="flash.events.IOErrorEvent", name="ioError")]
  /**
   * @copy flash.display.LoaderInfo
   */
  public interface ILoaderInfo extends IEventDispatcher
  {
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#actionScriptVersion
     */
    function get actionScriptVersion():uint;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#applicationDomain
     */
    function get applicationDomain():ApplicationDomain;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    [Bindable(event="progress")]
    /**
     * @copy flash.display.LoaderInfo#bytesLoaded
     */
    function get bytesLoaded():uint;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#bytesTotal
     */
    function get bytesTotal():uint;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#childAllowsParent
     */
    function get childAllowsParent():Boolean;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#content
     */
    function get content():DisplayObject;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#contentType
     */
    function get contentType():String;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#frameRate
     */
    function get frameRate():Number;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#height
     */
    function get height():int;
    
    /**
     * @copy flash.display.LoaderInfo#loader
     */
    function get loader():ILoader;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#loaderURL
     */
    function get loaderURL():String;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#parameters
     */
    function get parameters():Object;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#parentAllowsChild
     */
    function get parentAllowsChild():Boolean;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#sameDomain
     */
    function get sameDomain():Boolean;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#sharedEvents
     */
    function get sharedEvents():EventDispatcher;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#swfVersion
     */
    function get swfVersion():uint;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#url
     */
    function get url():String;
    
    [Bindable(event="init")]
    [Bindable(event="unload")]
    /**
     * @copy flash.display.LoaderInfo#width
     */
    function get width():int;

  }
}