package com.netease.recording
{
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  
  public class LoaderRecordPlugin extends RecordPlugin implements IRecordPlugin
  {
    public function LoaderRecordPlugin(manager:BaseRecordManager)
    {
      super(manager);
    }
    
    public function get targetType():Class
    {
      return ILoader;
    }
    
    public function newInstance(...args):*
    {
      return new RecordableLoader(manager);
    }
    
    public function get eventNames():Array
    {
      return [];
    }
    
    public function toXMLList(event:Event):XMLList
    {
      throw new IllegalOperationError();
    }
  }
}
