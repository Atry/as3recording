// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  import flash.display.DisplayObject;
  public class RecordPlugin
  {
    private var _manager:BaseRecordManager;
    
    protected final function get manager():BaseRecordManager
    {
      return _manager;
    }
    
    public function RecordPlugin(manager:BaseRecordManager)
    {
      _manager = manager;
    }

    protected final function displayObjectToXML(name:String,
                                                value:DisplayObject):XML
    {
      if (!value)
      {
        return <!-- ignore empty value. -->;
      }
      else
      {
        const path:XMLList = _manager.getDisplayPath(value);
        if (path)
        {
          return <{name}>{path}</{name}>;
        }
        else
        {
          try
          {
            return <{name} id={_manager.getRegisterObjectID(value)}/>;
          }
          catch(e:ArgumentError)
          {
            trace("Unrecordable object："value);
            return <!-- ignore unrecordable object -->;
          }
        }
      }
    }
    protected static function toXML(name:String, value:*):XML
    {
      if (value === "")
      {
        return <{name}></{name}>;
      }
      else if (!value)
      {
        return <!-- ignore empty value. -->;
      }
      else
      {
        return <{name}>{value}</{name}>;
      }
    }
  }
}