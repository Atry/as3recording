package com.netease.recording
{
  public final class PosterURLRequest
  {
    public var url:String;
    
    [ArrayElementType("flash.net.URLRequestHeader")]
    public var requestHeaders:Array;
    
    public var method:String = "PUT";
    
    public function PosterURLRequest(url:String)
    {
      this.url = url;
    }

  }
}