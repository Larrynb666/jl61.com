package events
{
   import flash.events.Event;
   
   public class LoaderEvent extends Event
   {
      
      public static const OPEN:String = Event.OPEN;
      
      public static const COMPLETE:String = Event.COMPLETE;
       
      
      private var _data;
      
      public function LoaderEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this._data = data;
         super(type,bubbles,cancelable);
      }
      
      override public function clone() : Event
      {
         return new LoaderEvent(type,this._data,bubbles,cancelable);
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}
