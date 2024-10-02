package net.play5d.kyo.display.ui.ppt.effect
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	
	public class PPTef_alpha extends BasePPTEffect
	{
		private var _tween:TweenLite;
		public function PPTef_alpha()
		{
			super();
		}
		
		protected override function initStart():void{
			_prevPic.alpha = 0;
			_nextPic.alpha = 0;
			_currentPic.alpha = 1;
		}
//		public override function initPrev():void{
//			_prevPic.alpha = 0;
//		}
//		public override function initNext():void{
//			_nextPic.alpha = 0;
//		}
		public override function tweenNext(back:Function):void{
			_tween = TweenLite.to(_nextPic,duration,{alpha:1,onComplete:back});
		}
		public override function tweenPrev(back:Function):void{
			_tween = TweenLite.to(_prevPic,duration,{alpha:1,onComplete:back});
		}
		public override function tweenBack():void{
			var t:Number = duration / 2;
			_tween = TweenLite.to(_sp,t,{alpha:1});
		}
		public override function tweening():Boolean{
			return _tween && _tween.active;
		}
		public override function tweenStop():void{
			if(_tween) _tween.kill();
		}
		
		
//		protected override function onDraging():void{
//			_sp.x = mousePoint().x - _downP.x;
//		}
//		protected override function dragNext():Boolean{
//			return _sp.x - _downSPP.x < -100;
//		}
//		protected override function dragPrev():Boolean{
//			return _sp.x - _downSPP.x > 100;
//		}
		
	}
}