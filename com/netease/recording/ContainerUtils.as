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
  
  internal final class ContainerUtils
  {
    internal static function getChildAt(parent:DisplayObjectContainer,
                                        index:int):DisplayObject
    {
      recording::flexEnabled
      {
        import mx.core.Container;
        const container:Container = parent as Container;
        if (container)
        {
          return container.rawChildren.getChildAt(index);
        }
      }
      return parent.getChildAt(index);
    }
    
    internal static function getChildIndex(parent:DisplayObjectContainer,
                                           child:DisplayObject):int
    {
      recording::flexEnabled
      {
        import mx.core.Container;
        const container:Container = parent as Container;
        if (container)
        {
          return container.rawChildren.getChildIndex(child);
        }
      }
      return parent.getChildIndex(child);
    }
    
    internal static function getParent(
      child:DisplayObject):DisplayObjectContainer
    {
      recording::flexEnabled
      {
        import mx.core.UIComponent;
        import mx.core.mx_internal;
        const uiComponent:UIComponent = child as UIComponent;
        if (uiComponent)
        {
          return uiComponent.mx_internal::$parent
        }
      }
      return child.parent;
    }
  }
}