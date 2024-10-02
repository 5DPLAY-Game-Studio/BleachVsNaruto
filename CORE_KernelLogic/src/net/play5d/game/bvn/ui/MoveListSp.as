package net.play5d.game.bvn.ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.events.SetBtnEvent;

	public class MoveListSp extends Sprite
	{
		[Embed(source="/../assets/movelist.jpg")]
		private var _picClass:Class;

		private var _pic:Bitmap;
		private var _btns:SetBtnGroup;

		public var onBackSelect:Function;

		public function MoveListSp()
		{
			super();

			_pic = new _picClass();
			_pic.width = GameConfig.GAME_SIZE.x;
			_pic.height = GameConfig.GAME_SIZE.y;

			addChild(_pic);

			_btns = new SetBtnGroup();
			_btns.setBtnData([{label:'BACK',cn:'返回'}]);
			_btns.addEventListener(SetBtnEvent.SELECT,onSelect);
			_btns.x = 250;
			_btns.y = GameConfig.GAME_SIZE.y - 130;
			addChild(_btns);
		}

		public function destory():void{
			if(_btns){
				_btns.removeEventListener(SetBtnEvent.SELECT,onSelect);
				_btns.destory();
				_btns = null;
			}
		}

		public function isShowing():Boolean{
			return this.visible;
		}

		public function show():void{

			this.visible = true;
			setTimeout(function():void{
				_btns.keyEnable = true;
			},100);
		}

		public function hide():void{
			_btns.keyEnable = false;
			this.visible = false;
		}

		private function onSelect(e:Event):void{
			if(onBackSelect != null) onBackSelect();
		}
	}
}
