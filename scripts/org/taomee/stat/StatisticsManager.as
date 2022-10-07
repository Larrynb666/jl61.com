package org.taomee.stat
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class StatisticsManager
   {
      
      private static const dirtyKeyList:Array = ["=",":",",",";",".","|","\t","&"];
      
      private static var _gameId:int = 0;
      
      private static var _enabled:Boolean = true;
       
      
      public function StatisticsManager()
      {
         super();
      }
      
      public static function setup(gameId:int) : void
      {
         _gameId = gameId;
      }
      
      public static function setEnabled(enabled:Boolean) : void
      {
         _enabled = enabled;
      }
      
      public static function sendHttpStat(stid:String, sstid:String, item:String = null, uid:int = 0) : String
      {
         var encodeItem:String = null;
         var encodeStid:String = encodeURI(replaceKey(stid));
         var encodeSstid:String = encodeURI(replaceKey(sstid));
         var url:String = "http://newmisc.taomee.com/misc.js?gameid=" + _gameId + "&stid=" + encodeStid + "&sstid=" + encodeSstid;
         if(uid)
         {
            url += "&uid=" + uid;
         }
         if(item)
         {
            encodeItem = encodeURI(replaceKey(item));
            url += "&item=" + encodeItem + "&itemlen=" + encodeItem.length;
         }
         url += "&stidlen=" + encodeStid.length + "&sstidlen=" + encodeSstid.length;
         send(url);
         return url;
      }
      
      public static function sentHttpValueStat(messageId:String, count:uint = 1) : void
      {
         send("http://newmisc.taomee.com/misc.txt?type=" + messageId + "&count=" + count);
      }
      
      public static function send(url:String) : void
      {
         var urlLoader:URLLoader = null;
         if(_enabled)
         {
            urlLoader = new URLLoader();
            addLoaderEvent(urlLoader);
            urlLoader.load(new URLRequest(url));
         }
      }
      
      private static function addLoaderEvent(urlLoader:URLLoader) : void
      {
         urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         urlLoader.addEventListener(Event.COMPLETE,completeHandler);
      }
      
      private static function removeLoaderEvent(urlLoader:URLLoader) : void
      {
         urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
         urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         urlLoader.removeEventListener(Event.COMPLETE,completeHandler);
      }
      
      private static function securityErrorHandler(event:SecurityErrorEvent) : void
      {
         var urlLoader:URLLoader = event.target as URLLoader;
         removeLoaderEvent(urlLoader);
      }
      
      private static function ioErrorHandler(event:IOErrorEvent) : void
      {
         var urlLoader:URLLoader = event.target as URLLoader;
         removeLoaderEvent(urlLoader);
      }
      
      private static function completeHandler(event:Event) : void
      {
         var urlLoader:URLLoader = event.target as URLLoader;
         urlLoader.close();
         removeLoaderEvent(urlLoader);
      }
      
      public static function replaceKey(text:String) : String
      {
         var dirtyKey:String = null;
         if(text)
         {
            for each(dirtyKey in dirtyKeyList)
            {
               if(text.indexOf(dirtyKey) >= 0)
               {
                  text = replaceText(text,dirtyKey,"_");
               }
            }
         }
         return text;
      }
      
      private static function replaceText(input:String, replace:String, replaceWith:String) : String
      {
         while(input.indexOf(replace) >= 0)
         {
            input = input.replace(replace,replaceWith);
         }
         return input;
      }
   }
}
