// Copyright (c) 2010, NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.recording
{
  public interface IRecorder
  {
    function newInstance(type:Class, ...args):*;

    /**
     * 功能等价于 <code>Math.random()</code>。
     * 调用本函数能保证录制和回放时取得相同的随机数。
     * 
     * @see Math.random()
     */
    function random():Number;
    
  }
}