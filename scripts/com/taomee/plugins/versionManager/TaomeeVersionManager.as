package com.taomee.plugins.versionManager
{
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   public class TaomeeVersionManager
   {
      
      public static var VERSION:uint = 20140805;
      
      public static var ALL_VERSION:String = "all";
      
      private static var _pvmDic:Dictionary = new Dictionary(true);
       
      
      private var _currentNameSpace:String;
      
      private var _bodyDic:Dictionary;
      
      private var _lastModifiedTime:uint;
      
      private var _fileLoader:TaomeeVersionLoader;
      
      private var _url:String;
      
      private var _loadedHandler:Function;
      
      private var _devRand:uint = 0;
      
      private var _isTrace:Boolean = false;
      
      public function TaomeeVersionManager(nameSpace:String)
      {
         this._bodyDic = new Dictionary(true);
         super();
         this._currentNameSpace = nameSpace;
         _pvmDic[nameSpace] = this;
      }
      
      public static function getInstance(nameSpace:String = "all") : TaomeeVersionManager
      {
         return Boolean(_pvmDic[nameSpace]) ? _pvmDic[nameSpace] : new TaomeeVersionManager(nameSpace);
      }
      
      public function set devModeEnabled(value:Boolean) : void
      {
         if(value)
         {
            if(!this._devRand)
            {
               this._devRand = int(Math.random() * 9999999);
            }
         }
         else
         {
            this._devRand = 0;
         }
      }
      
      public function set isTrace(value:Boolean) : void
      {
         this._isTrace = value;
      }
      
      public function destroy() : void
      {
         _pvmDic[this._currentNameSpace] = null;
         delete _pvmDic[this._currentNameSpace];
         this._bodyDic = null;
      }
      
      public function getVerURLByNameSpace(url:String, hasRandom:Boolean = false) : String
      {
         if(!url)
         {
            return "";
         }
         var hasQuestString:Boolean = false;
         var questString:String = "";
         var version:String = "";
         var varsArray:Array = url.split("?");
         if(varsArray.length > 1)
         {
            questString = varsArray[1];
            url = varsArray[0];
            hasQuestString = true;
         }
         var fileModifyTime:Number = this.getModifiedValue(url);
         if(fileModifyTime)
         {
            version = String(fileModifyTime.toString(36));
            if(questString.indexOf(version) != -1)
            {
               return Boolean(questString) ? url + "?" + questString : url;
            }
            if(fileModifyTime)
            {
               if(hasRandom)
               {
                  if(hasQuestString)
                  {
                     url = url + "?" + questString + "&" + version + "&" + Math.round(Math.random() * 1000);
                  }
                  else
                  {
                     url = url + "?" + version + "&" + Math.round(Math.random() * 1000);
                  }
               }
               else if(hasQuestString)
               {
                  url = url + "?" + questString + "&" + version;
               }
               else
               {
                  url = url + "?" + version;
               }
            }
            else if(hasRandom)
            {
               if(hasQuestString)
               {
                  url = url + "?" + questString + "&" + Math.round(Math.random() * 1000);
               }
               else
               {
                  url = url + "?" + Math.round(Math.random() * 1000);
               }
            }
            else if(hasQuestString)
            {
               url = url + "?" + questString;
            }
            else
            {
               url = url;
            }
         }
         if(this._isTrace)
         {
            trace("[URL]",url);
         }
         return url;
      }
      
      public function getModifiedDate(relativePath:String) : Date
      {
         return new Date(this.getModifiedValue(relativePath));
      }
      
      public function getModifiedValue(relativePath:String) : Number
      {
         while(relativePath.indexOf("\\") > -1)
         {
            relativePath = relativePath.replace("\\","/");
         }
         var value:Number = this._bodyDic[this.hashFileName(relativePath)];
         return !!isNaN(value) ? Number(this._devRand) : Number(value * 1000 + this._devRand);
      }
      
      private function hashFileName(filePath:String) : uint
      {
         var hash:uint = 0;
         var len:int = filePath.length;
         for(var i:int = 0; i < len; i++)
         {
            hash = filePath.charCodeAt(i) + (hash << 6) + (hash << 16) - hash;
         }
         return hash & 2147483647;
      }
      
      public function getURLRequest(urlParameter:*, hasRandom:Boolean = false) : URLRequest
      {
         var urlRequest:URLRequest = null;
         if(urlParameter is URLRequest)
         {
            urlRequest = urlParameter;
            urlRequest.url = this.getVerURLByNameSpace(urlRequest.url,hasRandom);
         }
         else
         {
            urlParameter = this.getVerURLByNameSpace(urlParameter,hasRandom);
            urlRequest = new URLRequest(urlParameter);
         }
         return urlRequest;
      }
      
      public function get lastModifiedDate() : Date
      {
         return new Date(this._lastModifiedTime * 1000);
      }
      
      public function load(url:String, loadedHandler:Function) : void
      {
         this._url = url;
         this._loadedHandler = loadedHandler;
         this.startLoad();
      }
      
      private function startLoad() : void
      {
         this._fileLoader = new TaomeeVersionLoader();
         this._fileLoader.addEventListener(TaomeeVersionEvent.VERSION_LOADED,this.versionLoadedHandler);
         this._fileLoader.addEventListener(TaomeeVersionEvent.VERSION_LOAD_ERROR,this.versionLoadErrorHandler);
         var url:String = this._url;
         var index:int = url.indexOf("?");
         if(index > -1)
         {
            url = url + "&" + int(Math.random() * 10000000);
         }
         else
         {
            url = url + "?" + int(Math.random() * 10000000);
         }
         this._fileLoader.load(url);
      }
      
      private function endLoad() : void
      {
         this._fileLoader.removeEventListener(TaomeeVersionEvent.VERSION_LOADED,this.versionLoadedHandler);
         this._fileLoader.removeEventListener(TaomeeVersionEvent.VERSION_LOADED,this.versionLoadErrorHandler);
         this._fileLoader = null;
      }
      
      private function versionLoadedHandler(event:TaomeeVersionEvent) : void
      {
         this._fileLoader.removeEventListener(TaomeeVersionEvent.VERSION_LOADED,this.versionLoadedHandler);
         var len:int = this._fileLoader.bodyData.readUnsignedInt();
         for(var i:int = 0; i < len; i++)
         {
            this._bodyDic[this._fileLoader.bodyData.readUnsignedInt()] = this._fileLoader.bodyData.readUnsignedInt();
         }
         this._lastModifiedTime = this._fileLoader.lastModifiedTime;
         if(this._loadedHandler != null)
         {
            this._loadedHandler();
         }
         this.endLoad();
      }
      
      private function versionLoadErrorHandler(event:TaomeeVersionEvent) : void
      {
         this.endLoad();
         setTimeout(this.startLoad,1000);
      }
   }
}
