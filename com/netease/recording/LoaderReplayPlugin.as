package com.netease.recording
{
  import flash.errors.IllegalOperationError;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  
  public class LoaderReplayPlugin extends ReplayPlugin implements IReplayPlugin
  {
    public function LoaderReplayPlugin(manager:BaseReplayManager)
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
    
    public function toEvent(target:IEventDispatcher, type:String, bubbles:Boolean, cancelable:Boolean, xml:XML):Event
    {
      throw new IllegalOperationError();
    }
  }
}