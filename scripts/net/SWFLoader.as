package net
{
   import events.LoaderEvent;
   import flash.display.Loader;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   
   public class SWFLoader extends EventDispatcher
   {
       
      
      private var _loader:Loader;
      
      public function SWFLoader()
      {
         super();
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadedHandler);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
      }
      
      public function load(url:String) : void
      {
         this._loader.load(new URLRequest(url));
      }
      
      public function destroy() : void
      {
         this._loader.unloadAndStop();
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.loadedHandler);
         this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         this._loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         this._loader = null;
      }
      
      private function loadedHandler(event:Event) : void
      {
         dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE,event.target.content));
      }
      
      private function progressHandler(event:ProgressEvent) : void
      {
         dispatchEvent(event);
      }
      
      private function ioErrorHandler(event:IOErrorEvent) : void
      {
         dispatchEvent(event);
         throw new IOError(event.text);
      }
      
      private function securityErrorHandler(event:SecurityErrorEvent) : void
      {
         dispatchEvent(event);
         throw new SecurityError(event.text);
      }
   }
}
