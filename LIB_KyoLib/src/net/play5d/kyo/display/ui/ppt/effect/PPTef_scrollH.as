package net.play5d.kyo.display.ui.ppt.effect
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class PPTef_scrollH extends BasePPTEffect
	{
		private var _tween:TweenLite;
		
		public var direct:int = 1;
		
		public function PPTef_scrollH(direct:int=1)
		{
			super();
			this.direct = direct;
		}
		
		protected override function initStart():void{
			_sp.x = 0;
			_currentPic.x = 0;
			
			switch(direct){
				case 1:
					_prevPic.x = -_pointer.size.x;
					_nextPic.x = _pointer.size.x;
					break;
				case -1:
					_prevPic.x = _pointer.size.x;
					_nextPic.x = -_pointer.size.x;
					break;
			}
		}
//		public override function initPrev():void{
//			_prevPic.x = -_pointer.size.x;
//		}
//		public override function initNext():void{
//			_nextPic.x = _pointer.size.x;
//		}
		public override function tweenNext(back:Function):void{
			switch(direct){
				case 1:
					_tween = TweenLite.to(_sp,duration,{x:-_size.x,onComplete:back});
					break;
				case -1:
					_tween = TweenLite.to(_sp,duration,{x:_size.x,onComplete:back});
					break;
			}
		}
		public override function tweenPrev(back:Function):void{
			switch(direct){
				case 1:
					_tween = TweenLite.to(_sp,duration,{x:_size.x,onComplete:back});
					break;
				case -1:
					_tween = TweenLite.to(_sp,duration,{x:-_size.x,onComplete:back});
					break;
			}
		}
		
		public override function tweenBack():void{
			var t:Number = duration / 2;
			_tween = TweenLite.to(_sp,t,{x:0});
		}
		public override function tweening():Boolean{
			return _tween && _tween.active;
		}
		public override function tweenStop():void{
			if(_tween) _tween.kill();
		}
		
		
		protected override function onDraging():void{
			_sp.x = mousePoint().x - _downP.x;
		}
		protected override function dragNext():Boolean{
			return _sp.x - _downSPP.x < -100;
		}
		protected override function dragPrev():Boolean{
			return _sp.x - _downSPP.x > 100;
		}
	}
}