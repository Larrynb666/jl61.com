package net
{
   import com.taomee.plugins.versionManager.TaomeeVersionManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.events.TextEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class DLLLoader extends EventDispatcher
   {
       
      
      private var _dllList:Array;
      
      private var _stream:URLStream;
      
      private var _loader:Loader;
      
      public function DLLLoader()
      {
         super();
         this._stream = new URLStream();
         this._stream.addEventListener(Event.OPEN,this.onOpen);
         this._stream.addEventListener(Event.COMPLETE,this.onComplete);
         this._stream.addEventListener(ProgressEvent.PROGRESS,this.onProgressHandler);
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderOver);
      }
      
      public function doLoad(xmlData:XML) : void
      {
         var item:XML = null;
         var info:DLLInfo = null;
         this._dllList = [];
         var xmlList:XMLList = xmlData.elements();
         for each(item in xmlList)
         {
            info = new DLLInfo();
            info.name = item.@name;
            info.path = item.@path;
            this._dllList.push(info);
         }
         this.beginLoad();
      }
      
      public function beginLoad() : void
      {
         var info:DLLInfo = null;
         if(this._dllList.length > 0)
         {
            info = this._dllList[0];
            this._stream.load(new URLRequest(TaomeeVersionManager.getInstance().getVerURLByNameSpace(info.path)));
         }
         else
         {
            this._stream.removeEventListener(Event.OPEN,this.onOpen);
            this._stream.removeEventListener(Event.COMPLETE,this.onComplete);
            this._stream.removeEventListener(ProgressEvent.PROGRESS,this.onProgressHandler);
            this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaderOver);
            this._loader = null;
            this._stream = null;
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function onOpen(e:Event) : void
      {
         var info:DLLInfo = this._dllList[0];
         dispatchEvent(new TextEvent(Event.OPEN,false,false,"加载" + info.name));
      }
      
      private function onProgressHandler(e:ProgressEvent) : void
      {
         dispatchEvent(e);
      }
      
      private function onComplete(e:Event) : void
      {
         var info:DLLInfo = this._dllList[0];
         var byteArray:ByteArray = new ByteArray();
         this._stream.readBytes(byteArray);
         this._stream.close();
         this._loader.loadBytes(byteArray,new LoaderContext(false,ApplicationDomain.currentDomain));
      }
      
      private function onLoaderOver(e:Event) : void
      {
         this._dllList.shift();
         this.beginLoad();
      }
   }
}

class DLLInfo
{
    
   
   public var name:String;
   
   public var path:String;
   
   function DLLInfo()
   {
      super();
   }
}
