// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  public function getEventNames(eventType:Class):Array
  {
    import flash.utils.describeType
    const xmlNames:XMLList = describeType(eventType).constant.@name;
    const result:Array = []
    for each(var fieldName:String in xmlNames)
    {
      result.push(eventType[fieldName]);
    }
    return result;
  }

}