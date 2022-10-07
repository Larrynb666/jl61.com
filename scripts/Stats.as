package
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.StatusEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.LocalConnection;
   import flash.system.System;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   
   public class Stats extends Sprite
   {
      
      private static var _lastFps:uint = 0;
       
      
      private const WIDTH:uint = 70;
      
      private const HEIGHT:uint = 100;
      
      private var _xml:XML;
      
      private var _stage:Stage;
      
      private var _text:TextField;
      
      private var _style:StyleSheet;
      
      private var _timer:uint;
      
      private var _fps:uint;
      
      private var _ms:uint;
      
      private var _msPrev:uint;
      
      private var _mem:Number;
      
      private var _memMax:Number;
      
      private var _graph:BitmapData;
      
      private var _rect:Rectangle;
      
      private var _fpsGraph:uint;
      
      private var _memGraph:uint;
      
      private var _memMaxGraph:uint;
      
      private var _colors:Colors;
      
      private var _conn:LocalConnection;
      
      private var _obj:Object;
      
      private var _step:uint = 0;
      
      public function Stats(stage:Stage)
      {
         this._colors = new Colors();
         this._obj = new Object();
         super();
         this._stage = stage;
         this._memMax = 0;
         this._xml = <xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax></xml>;
         this._style = new StyleSheet();
         this._style.setStyle("xml",{
            "fontSize":"9px",
            "fontFamily":"_sans",
            "leading":"-2px"
         });
         this._style.setStyle("fps",{"color":this.hex2css(this._colors.fps)});
         this._style.setStyle("ms",{"color":this.hex2css(this._colors.ms)});
         this._style.setStyle("mem",{"color":this.hex2css(this._colors.mem)});
         this._style.setStyle("memMax",{"color":this.hex2css(this._colors.memmax)});
         this._text = new TextField();
         this._text.width = this.WIDTH;
         this._text.height = 50;
         this._text.styleSheet = this._style;
         this._text.condenseWhite = true;
         this._text.selectable = false;
         this._text.mouseEnabled = false;
         this._rect = new Rectangle(this.WIDTH - 1,0,1,this.HEIGHT - 50);
         addEventListener(Event.ADDED_TO_STAGE,this.init,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.destroy,false,0,true);
         this._conn = new LocalConnection();
         this._conn.allowDomain("*");
         this._conn.addEventListener(StatusEvent.STATUS,this.onStatus);
         this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keydownHandler);
         this._stage.addEventListener(Event.RESIZE,this.resizeHandler);
         this._stage.addChild(this);
         this.resizeHandler();
      }
      
      public static function get fps() : uint
      {
         return _lastFps;
      }
      
      private function keydownHandler(event:KeyboardEvent) : void
      {
         if(event.keyCode == Keyboard.INSERT)
         {
            if(parent)
            {
               parent.removeChild(this);
            }
            else
            {
               this._stage.addChild(this);
               this.resizeHandler();
            }
         }
      }
      
      private function resizeHandler(event:Event = null) : void
      {
         var _point:Point = null;
         if(parent)
         {
            _point = parent.globalToLocal(new Point(20,200));
            this.x = _point.x;
            this.y = _point.y;
         }
      }
      
      private function onStatus(event:StatusEvent) : void
      {
         switch(event.level)
         {
            case "status":
               break;
            case "error":
         }
      }
      
      private function init(e:Event) : void
      {
         graphics.beginFill(this._colors.bg);
         graphics.drawRect(0,0,this.WIDTH,this.HEIGHT);
         graphics.endFill();
         addChild(this._text);
         this._graph = new BitmapData(this.WIDTH,this.HEIGHT - 50,true,this._colors.bg);
         graphics.beginBitmapFill(this._graph,new Matrix(1,0,0,1,0,50));
         graphics.drawRect(0,50,this.WIDTH,this.HEIGHT - 50);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(Event.ENTER_FRAME,this.update);
      }
      
      private function destroy(e:Event) : void
      {
         graphics.clear();
         while(numChildren > 0)
         {
            removeChildAt(0);
         }
         this._graph.dispose();
         removeEventListener(MouseEvent.CLICK,this.onClick);
         removeEventListener(Event.ENTER_FRAME,this.update);
      }
      
      private function update(e:Event) : void
      {
         this._timer = getTimer();
         if(this._timer - 1000 > this._msPrev)
         {
            this._msPrev = this._timer;
            this._mem = Number((System.totalMemory * 9.54e-7).toFixed(3));
            this._memMax = this._memMax > this._mem ? Number(this._memMax) : Number(this._mem);
            this._fpsGraph = Math.min(this._graph.height,this._fps / stage.frameRate * this._graph.height);
            this._memGraph = Math.min(this._graph.height,Math.sqrt(Math.sqrt(this._mem * 5000))) - 2;
            this._memMaxGraph = Math.min(this._graph.height,Math.sqrt(Math.sqrt(this._memMax * 5000))) - 2;
            this._graph.scroll(-1,0);
            this._graph.fillRect(this._rect,this._colors.bg);
            this._graph.setPixel(this._graph.width - 1,this._graph.height - this._fpsGraph,this._colors.fps);
            this._graph.setPixel(this._graph.width - 1,this._graph.height - (this._timer - this._ms >> 1),this._colors.ms);
            this._graph.setPixel(this._graph.width - 1,this._graph.height - this._memGraph,this._colors.mem);
            this._graph.setPixel(this._graph.width - 1,this._graph.height - this._memMaxGraph,this._colors.memmax);
            this._xml.fps = "FPS: " + this._fps + " / " + stage.frameRate;
            this._obj.fps = this._fps;
            this._xml.mem = "MEM: " + this._mem;
            this._xml.memMax = "MAX: " + this._memMax;
            _lastFps = this._fps;
            this._fps = 0;
         }
         ++this._fps;
         this._xml.ms = "MS: " + (this._timer - this._ms);
         this._obj.stageFps = stage.frameRate;
         this._obj.mem = this._mem;
         this._obj.memMax = this._memMax;
         this._obj.ms = this._timer - this._ms;
         this._ms = this._timer;
         this._text.htmlText = this._xml;
         ++this._step;
         if(this._step == 33)
         {
            this._conn.send("_myConnection","postFPS",this._obj);
            this._step = 0;
         }
      }
      
      private function onClick(e:MouseEvent) : void
      {
         if(mouseY / height > 0.5)
         {
            --stage.frameRate;
         }
         else
         {
            ++stage.frameRate;
         }
         this._xml.fps = "FPS: " + this._fps + " / " + stage.frameRate;
         this._text.htmlText = this._xml;
      }
      
      private function hex2css(color:int) : String
      {
         return "#" + color.toString(16);
      }
   }
}

class Colors
{
    
   
   public var bg:uint = 2.281701427E9;
   
   public var fps:uint = 16776960;
   
   public var ms:uint = 65280;
   
   public var mem:uint = 65535;
   
   public var memmax:uint = 16711792;
   
   function Colors()
   {
      super();
   }
}
