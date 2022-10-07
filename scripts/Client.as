package
{
   import com.taomee.plugins.versionManager.TaomeeVersionManager;
   import events.LoaderEvent;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.media.Sound;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.system.System;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import net.DLLLoader;
   import net.SWFLoader;
   import net.XMLLoader;
   import org.taomee.stat.StatisticsManager;
   
   [SWF(frameRate="24",backgroundColor="#000000",width="1200",height="660")]
   public class Client extends Sprite
   {
       
      
      private var _mcLoad:MovieClip;
      
      private var _mcSleep:MovieClip;
      
      private var _mcLauncher:Sprite;
      
      private var _mcLogo:Sprite;
      
      private var _xmlloader:XMLLoader;
      
      private var _dllLoader:DLLLoader;
      
      private var _isDllLoaded:Boolean;
      
      private var _launcherLoader:SWFLoader;
      
      private var _logoLoader:SWFLoader;
      
      private var _isDebug:Boolean;
      
      private var _serverURL:String;
      
      private var _versionURL:String;
      
      private var _launcherURL:String;
      
      private var _dllXML:XML;
      
      private var _configXML:XML;
      
      private var _serviceXML:XML;
      
      private var _controlXML:XML;
      
      private var _serverXML:XML;
      
      private var _isBattle:Boolean;
      
      private var _isServerLoaded:Boolean;
      
      private var _serverList:Array;
      
      private var _isEnterClick:Boolean;
      
      private var _multiVersionTag:String = "";
      
      public function Client()
      {
         super();
         setTimeout(this.initialize,1);
         Security.allowDomain("*");
         StatisticsManager.setup(16);
      }
      
      public static function getVersionView() : String
      {
         var versionDate:Date = TaomeeVersionManager.getInstance().lastModifiedDate;
         return versionDate.fullYear + "." + (versionDate.getMonth() + 1) + "." + versionDate.getDate() + " " + versionDate.toLocaleTimeString();
      }
      
      private function initialize() : void
      {
         var loader:Loader = null;
         var sound:Sound = null;
         var contextItem:ContextMenuItem = null;
         stage.stageFocusRect = false;
         stage.align = StageAlign.TOP_LEFT;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         var isClose:Boolean = false;
         if(ExternalInterface.available)
         {
            isClose = ExternalInterface.call("isClose") > 0;
            this._isBattle = ExternalInterface.call("isBattle") > 0;
         }
         if(isClose)
         {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.sleepLoadedHandler);
            loader.load(new URLRequest("Close.swf"));
         }
         else
         {
            sound = new Sound(new URLRequest(""));
            sound.play();
            sound.close();
            contextMenu = new ContextMenu();
            contextItem = new ContextMenuItem("您的Flash播放器版本：" + Capabilities.version);
            contextMenu.hideBuiltInItems();
            contextMenu.customItems.push(contextItem);
            this._mcLoad = new ProgressUI();
            addChild(this._mcLoad);
            this._mcLoad.visible = false;
            stage.addEventListener(Event.RESIZE,this.layout);
            this.layout(null);
            this.initExternalCall();
            this.loadConfig();
         }
      }
      
      private function loadConfig() : void
      {
         this._xmlloader = new XMLLoader();
         this._xmlloader.addEventListener(LoaderEvent.COMPLETE,this.onConfigXMLComplete);
         this._xmlloader.load("config/blitz.xml?v=" + new Date().time);
      }
      
      private function onConfigXMLComplete(event:LoaderEvent) : void
      {
         var ccc:XML = null;
         var endDate:Array = null;
         this._xmlloader.removeEventListener(LoaderEvent.COMPLETE,this.onConfigXMLComplete);
         var configXML:XML = event.data;
         this._isDebug = int(configXML.debug) > 0;
         this._launcherURL = String(configXML.launcher[0].item[0].@path);
         this._versionURL = String(configXML.version);
         this._serverURL = String(configXML.server);
         this._dllXML = !!this._isBattle ? configXML.battledll[0] : configXML.dll[0];
         var now:Number = new Date().time;
         var multiVersions:XMLList = configXML.multiVersion.version;
         var lll:uint = multiVersions.length();
         for(var i:uint = 0; i < lll; i++)
         {
            endDate = String(multiVersions[i].@endDate).split("-");
            if(now < new Date(uint(endDate[0]),uint(endDate[1] - 1),uint(endDate[2])).time)
            {
               this._multiVersionTag = String(multiVersions[i].@tag);
               break;
            }
         }
         if(int(configXML.usepack) > 0)
         {
            this._configXML = configXML.configpack[0];
         }
         else
         {
            this._configXML = configXML.configall[0];
         }
         this._serviceXML = configXML.service[0];
         this._controlXML = configXML.control[0];
         this.loadVersion();
      }
      
      private function loadVersion() : void
      {
         TaomeeVersionManager.getInstance().load(this._versionURL,this.onVersionComplete);
         TaomeeVersionManager.getInstance().devModeEnabled = this._isDebug;
      }
      
      private function onVersionComplete() : void
      {
         var clientVersionItem:ContextMenuItem = new ContextMenuItem("您的客户端版本：" + getVersionView());
         contextMenu.customItems.push(clientVersionItem);
         clientVersionItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
         {
            System.setClipboard(getVersionView());
         });
         this.loadServerXML();
      }
      
      private function loadServerXML() : void
      {
         this._xmlloader.addEventListener(LoaderEvent.COMPLETE,this.onServerXMLComplete);
         this._xmlloader.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         var url:String = TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._serverURL) + "?v=" + int(Math.random() * 100000);
         this._xmlloader.load(url);
      }
      
      private function onServerXMLComplete(event:LoaderEvent) : void
      {
         this._xmlloader.removeEventListener(LoaderEvent.COMPLETE,this.onServerXMLComplete);
         this._xmlloader.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._xmlloader.destroy();
         this._xmlloader = null;
         this._serverXML = event.data;
         this.loadLogo();
      }
      
      private function loadLogo() : void
      {
         this._logoLoader = new SWFLoader();
         this._logoLoader.addEventListener(LoaderEvent.COMPLETE,this.logoLoadedHandler);
         this._logoLoader.load(TaomeeVersionManager.getInstance().getVerURLByNameSpace("dll/logo.swf"));
      }
      
      private function logoLoadedHandler(event:LoaderEvent) : void
      {
         this._mcLoad.visible = false;
         this._mcLogo = event.data as Sprite;
         addChildAt(this._mcLogo,0);
         setTimeout(function():void
         {
            removeChildAt(0);
            _logoLoader.destroy();
            _logoLoader = null;
            loadLauncher();
         },1500);
      }
      
      private function loadLauncher() : void
      {
         this._launcherLoader = new SWFLoader();
         this._launcherLoader.addEventListener(LoaderEvent.COMPLETE,this.launcherLoadedHandler);
         this._launcherLoader.load(TaomeeVersionManager.getInstance().getVerURLByNameSpace(this._launcherURL));
      }
      
      private function launcherLoadedHandler(event:LoaderEvent) : void
      {
         this._mcLoad.visible = false;
         this._mcLauncher = event.data as Sprite;
         this._mcLauncher["setData"](this._serverXML,this.startGameHandler,this.serverCompleteHandler,this._multiVersionTag);
         addChildAt(this._mcLauncher,0);
         StatisticsManager.sentHttpValueStat("0x21001054",getTimer() * 0.001);
         this.loadDLL();
      }
      
      private function startGameHandler() : void
      {
         this._isEnterClick = true;
         this.startupDll();
      }
      
      private function serverCompleteHandler(srvList:Array) : void
      {
         this._serverList = srvList;
         this._isServerLoaded = true;
         this.startupDll();
      }
      
      private function loadDLL() : void
      {
         this._dllLoader = new DLLLoader();
         this._dllLoader.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._dllLoader.addEventListener(Event.COMPLETE,this.onDLLComplete);
         this._dllLoader.doLoad(this._dllXML);
      }
      
      private function startupDll() : void
      {
         var clientApp:* = undefined;
         var contextView:Sprite = null;
         if(this._isServerLoaded && this._isDllLoaded && this._isEnterClick)
         {
            this._mcLauncher.mouseEnabled = false;
            this._mcLauncher.mouseChildren = false;
            this._mcLoad.visible = true;
            clientApp = !!this._isBattle ? getDefinitionByName("com.taomee.blitz.battle.ClientBattle") : getDefinitionByName("com.taomee.blitz.app.ClientApp");
            contextView = new Sprite();
            addChildAt(contextView,0);
            removeChild(this._mcLoad);
            if(ExternalInterface.available)
            {
               stage.removeEventListener(Event.RESIZE,this.layout);
            }
            contextView.addEventListener("destroy launcher",function(event:Event):void
            {
               contextView.removeEventListener("destroy launcher",arguments.callee);
               _mcLauncher["destroy"]();
               _mcLauncher = null;
            });
            if(this._isBattle)
            {
               clientApp.setup(contextView,this._configXML,this._serviceXML,this._controlXML,this._serverXML,this._isDebug);
            }
            else
            {
               clientApp.setMultiVersionTag(this._multiVersionTag);
               clientApp.setup(contextView,this._configXML,this._serviceXML,this._controlXML,this._serverXML,this._serverList,this._isDebug);
            }
            if(this._isDebug)
            {
               addChild(new Stats(stage));
            }
            this._mcLoad = null;
            this._dllXML = null;
            this._configXML = null;
            this._serviceXML = null;
            this._controlXML = null;
            this._serverXML = null;
            this._isEnterClick = false;
         }
      }
      
      private function onDLLComplete(e:Event) : void
      {
         this._dllLoader.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._dllLoader.removeEventListener(Event.COMPLETE,this.onDLLComplete);
         this._dllLoader = null;
         this._isDllLoaded = true;
         this.startupDll();
      }
      
      private function onProgress(event:ProgressEvent) : void
      {
         var percent:int = event.bytesLoaded / event.bytesTotal * 100;
         this._mcLoad["mc"].gotoAndStop(percent);
         this._mcLoad["pet"].gotoAndStop(percent);
      }
      
      private function initExternalCall() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("fit_size");
         }
      }
      
      private function sleepLoadedHandler(event:Event) : void
      {
         this._mcSleep = event.target.content as MovieClip;
         this._mcSleep["btnBBS"].addEventListener(MouseEvent.CLICK,function(event:MouseEvent):void
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("window.open","http://bbs.61.com/forum.php?mod=forumdisplay&fid=171","_blank");
            }
         });
         addChildAt(this._mcSleep,0);
         this.layout(null);
         setTimeout(function():void
         {
            layout(null);
         },1);
         this.initExternalCall();
         this.sleepTimeHandler(null);
         var timer:Timer = new Timer(1000);
         timer.addEventListener(TimerEvent.TIMER,this.sleepTimeHandler);
         timer.start();
      }
      
      private function sleepTimeHandler(event:TimerEvent) : void
      {
         var now:Date = null;
         var tomorrow:Date = null;
         var time:int = 0;
         var hours:int = 0;
         var minutes:int = 0;
         var seconds:int = 0;
         if(this._mcSleep)
         {
            now = new Date();
            tomorrow = new Date();
            tomorrow.hours = 6;
            tomorrow.minutes = 0;
            tomorrow.seconds = 0;
            if(now.hours >= 6)
            {
               tomorrow.dateUTC += 1;
            }
            now.time = tomorrow.time - now.time;
            time = now.time * 0.001;
            hours = Math.max(time / 3600,0);
            minutes = Math.max((time - hours * 3600) / 60,0);
            seconds = Math.max(time - hours * 3600 - minutes * 60,0);
            this._mcSleep["mcHour0"].gotoAndStop(hours >= 10 ? int(hours / 10) + 1 : 1);
            this._mcSleep["mcHour1"].gotoAndStop(int(hours % 10) + 1);
            this._mcSleep["mcMinute0"].gotoAndStop(minutes >= 10 ? int(minutes / 10) + 1 : 1);
            this._mcSleep["mcMinute1"].gotoAndStop(int(minutes % 10) + 1);
            this._mcSleep["mcSecond0"].gotoAndStop(seconds >= 10 ? int(seconds / 10) + 1 : 1);
            this._mcSleep["mcSecond1"].gotoAndStop(int(seconds % 10) + 1);
         }
      }
      
      private function layout(event:Event) : void
      {
         if(this._mcLoad)
         {
            this._mcLoad.x = stage.stageWidth / 2;
            this._mcLoad.y = stage.stageHeight / 2;
         }
         if(this._mcSleep)
         {
            this._mcSleep.x = stage.stageWidth / 2;
            this._mcSleep.y = stage.stageHeight / 2;
         }
      }
   }
}
