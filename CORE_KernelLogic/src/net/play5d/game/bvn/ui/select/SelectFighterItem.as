package net.play5d.game.bvn.ui.select
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.SelectCharListItemVO;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.display.BitmapText;
	
	/**
	 * 小头像 
	 * @author weijian
	 * 
	 */
	public class SelectFighterItem extends EventDispatcher
	{
		
		public static function getIdByPoint(X:int, Y:int):String{
			return X + ',' + Y;
		}
		
		public function get positionId():String{
			return getIdByPoint(position.x, position.y);
		}
		
		public var selectData:SelectCharListItemVO;
		public var fighterData:FighterVO;
		
		public var ui:slt_item_mc = ResUtils.I.createDisplayObject(ResUtils.swfLib.select , 'slt_item_mc');
		
		public var position:Point = new Point();
		
		public var isMore:Boolean = false;
		
		private var faceSize:Point = new Point(50,50);
		
		private var _moreText:BitmapText;
		
		public function SelectFighterItem(fighterData:FighterVO , selectData:SelectCharListItemVO, isMore:Boolean = false)
		{
			super();
			
			this.isMore = isMore;
			
			this.selectData = selectData;
			this.fighterData = fighterData;
			
			var face:DisplayObject = AssetManager.I.getFighterFace(fighterData);
			if(face) ui.ct.addChild(face);
			
			ui.mouseChildren = false;
			ui.buttonMode = true;
			
			if(selectData && selectData.moreFighterIDs){
				initMoreUI();
			}
			
			if(ui.more_bg){
				ui.more_bg.visible = isMore;
				ui.more_bg.mouseEnabled = ui.more_bg.mouseChildren = false;
				var cr:ColorTransform = new ColorTransform();
				cr.greenOffset = 255;
				cr.blueOffset = -255;
				ui.more_bg.transform.colorTransform = cr;
			}
		}
		
		private function initMoreUI():void{
			var txt:BitmapText = new BitmapText(false, 0xffff00, [new GlowFilter(0,1,5,5,3)]);
			txt.width = 50;
			txt.defaultTextFormat.bold = true;
			txt.defaultTextFormat.color = 0xffff00;
			txt.defaultTextFormat.size = 16;
			txt.align = TextFormatAlign.RIGHT;
			txt.y = -3;
			txt.text = selectData.moreFighterIDs.length + "+";
			txt.update();
			ui.addChild(txt);
			
			_moreText = txt;
		}
		
		public function setMoreNumberVisible(v:Boolean):void{
			if(_moreText) _moreText.visible = v;
		}
		
		private var _listeners:Object = {};
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			if(ui.hasEventListener(type)) return;
			ui.addEventListener(type,selfHandler,useCapture,priority,useWeakReference);
			_listeners[type] = listener;
		}
		public function removeAllEventListener():void{
			for(var i:String in _listeners){
				ui.removeEventListener(i,_listeners[i]);
			}
			_listeners = {};
		}
		private function selfHandler(e:Event):void{
			_listeners[e.type](e.type , this);
		}
		
		
		private var _tweenFrom:Point;
		private var _tweenTo:Point;
		public function initMoreTween(fromP:Point, toP:Point):void{
			_tweenFrom = fromP;
			_tweenTo = toP;
		}
		
		public function showMore(delay:Number = 0.1):void{
			ui.x = _tweenFrom.x;
			ui.y = _tweenFrom.y;
			ui.mouseEnabled = false;
			TweenLite.to(ui, 0.2, {x: _tweenTo.x, y: _tweenTo.y, ease: Back.easeOut, delay: delay, onComplete: function():void{
				ui.mouseEnabled = true;
			}});
		}
		public function hideMore():void{
			TweenLite.to(ui, 0.1, {x: _tweenFrom.x, y: _tweenFrom.y, onComplete: function():void{
				try{
					ui.parent.removeChild(ui);
				}catch(e:Error){}
			}});
		}
		
		
		public function destory():void{
			if(ui){
				removeAllEventListener();
			}
			if(ui && ui.parent){
				try{
					ui.parent.removeChild(ui);
				}catch(e:Error){}
				ui = null;
			}
		}
		
	}
}