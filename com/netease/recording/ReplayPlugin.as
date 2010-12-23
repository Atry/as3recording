// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.InteractiveObject;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  
  public class ReplayPlugin
  {
    private var _manager:BaseReplayManager;
    
    protected function get manager():BaseReplayManager
    {
      return _manager;
    }
    
    public function ReplayPlugin(manager:BaseReplayManager)
    {
      _manager = manager
    }
    
    protected final function toInteractiveObject(xml:XMLList):InteractiveObject
    {
      if (xml.length() == 0)
      {
        return null;
      }
      else
      {
        const idXML:XMLList = xml.@id;
        if (idXML.length() != 0)
        {
          return _manager.releaseRegisteredObject(uint(idXML));
        }
        else
        {
          try
          {
            return InteractiveObject(_manager.locateDisplayObject(xml.childAt));
          }
          catch(e:RangeError)
          {
            trace("Warning: Object not found.", xml);
          }
          return null;
        }
      }
    }
    
    protected static function xmlToString(xml:XMLList):String
    {
      if (xml.length() == 0)
      {
        return null;
      }
      else
      {
        return xml.text();
      }
    }
    
    protected static function toBoolean(xml:XMLList):Boolean
    {
      if (xml.length() == 0)
      {
        return false;
      }
      const text:String = xml.text()
      if (text == "" || text == "false")
      {
        return false;
      }
      else
      {
        return true;
      }
    }
    
    public function beforeDispatch(xml:XML,
                                   target:IEventDispatcher,
                                   event:Event):void
    {
    }
    
    public function afterDispatch(xml:XML,
                                  target:IEventDispatcher,
                                  event:Event):void
    {
    }
  }
}