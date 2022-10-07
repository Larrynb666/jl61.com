package com.taomee.plugins.versionManager
{
   import flash.events.Event;
   
   public class TaomeeVersionEvent extends Event
   {
      
      public static const VERSION_LOADED:String = "versionLoaded";
      
      public static const VERSION_LOAD_ERROR:String = "versionLoadError";
       
      
      public function TaomeeVersionEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
      
      override public function clone() : Event
      {
         return new TaomeeVersionEvent(type,bubbles,cancelable);
      }
   }
}
