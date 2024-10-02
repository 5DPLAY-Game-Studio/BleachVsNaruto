package net.play5d.game.bvn.ui.dialog.select
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	
	import net.play5d.game.bvn.GameConfig;
	
	public class DotsGroupUI extends Sprite
	{
		private var _dotArr:Array;
		public var onDotClick:Function;
		
		public function DotsGroupUI()
		{
			super();
		}
		
		public function update(total:int):void{
			_dotArr = [];
			
			for(var i:int; i < total; i++){
				var dot:DotItemUI = new DotItemUI();
				dot.page = i + 1;
				
				addChild(dot.getUI());
				
				_dotArr.push(dot);
				
				dot.getUI().x = i * 40;
				
				if(GameConfig.TOUCH_MODE){
					dot.getUI().addEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				}else{
					dot.getUI().addEventListener(MouseEvent.CLICK, mouseHandler);
				}
				
				
				if(i == 0){
					dot.focus(true);
				}
			}
		}
		
		public function updateByPage(v:int):void{
			for each(var d:DotItemUI in _dotArr){
				d.focus(d.page == v);
			}
		}
		
		public function destory():void{
			for each(var d:DotItemUI in _dotArr){
				d.getUI().removeEventListener(TouchEvent.TOUCH_TAP, touchHandler);
				d.getUI().removeEventListener(MouseEvent.CLICK, mouseHandler);
			}
		}
		
		private function mouseHandler(e:MouseEvent):void{
			doClick(e.currentTarget);
		}
		
		private function touchHandler(e:TouchEvent):void{
			doClick(e.currentTarget);
		}
		
		private function doClick(target:Object):void{
			if(onDotClick == null) return;
			
			var curUI:DisplayObject = target as DisplayObject;
			
			for each(var d:DotItemUI in _dotArr){
				if(d.getUI() == curUI){
					onDotClick(d.page);
				}
			}
		}
	}
}