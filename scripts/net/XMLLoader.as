package net
{
   import events.LoaderEvent;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   
   public class XMLLoader extends EventDispatcher
   {
       
      
      private var _xmlloader:URLStream;
      
      private var _isCompress:Boolean;
      
      public function XMLLoader()
      {
         super();
         this._xmlloader = new URLStream();
         this._xmlloader.addEventListener(Event.COMPLETE,this.onComplete);
         this._xmlloader.addEventListener(Event.OPEN,this.onOpen);
         this._xmlloader.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._xmlloader.addEventListener(IOErrorEvent.IO_ERROR,this.onIoError);
         this._xmlloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
      }
      
      public function load(url:String, isCompress:Boolean = false) : void
      {
         this._xmlloader.load(new URLRequest(url));
         this._isCompress = isCompress;
      }
      
      public function close() : void
      {
         if(this._xmlloader.connected)
         {
            this._xmlloader.close();
         }
      }
      
      public function destroy() : void
      {
         this.close();
         this._xmlloader.removeEventListener(Event.COMPLETE,this.onComplete);
         this._xmlloader.removeEventListener(Event.OPEN,this.onOpen);
         this._xmlloader.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._xmlloader.removeEventListener(IOErrorEvent.IO_ERROR,this.onIoError);
         this._xmlloader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         this._xmlloader = null;
      }
      
      private function onOpen(e:Event) : void
      {
         dispatchEvent(e);
      }
      
      private function onComplete(e:Event) : void
      {
         var data:ByteArray = new ByteArray();
         this._xmlloader.readBytes(data);
         if(this._isCompress)
         {
            data.uncompress();
         }
         dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE,XML(data.readUTFBytes(data.bytesAvailable))));
      }
      
      private function onProgress(e:ProgressEvent) : void
      {
         dispatchEvent(e);
      }
      
      private function onIoError(e:IOErrorEvent) : void
      {
         dispatchEvent(e);
         throw new IOError(e.text);
      }
      
      private function onSecurityError(e:SecurityErrorEvent) : void
      {
         dispatchEvent(e);
         throw new SecurityError(e.text);
      }
   }
}
