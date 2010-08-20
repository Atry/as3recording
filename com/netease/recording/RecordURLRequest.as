package com.netease.recording
{
  public final class RecordURLRequest
  {
    public var url:String;
    
    [ArrayElementType("flash.net.URLRequestHeader")]
    public var requestHeaders:Array;
    
    public var method:String = "PUT";
    
    public function RecordURLRequest(url:String)
    {
      this.url = url;
    }

  }
}