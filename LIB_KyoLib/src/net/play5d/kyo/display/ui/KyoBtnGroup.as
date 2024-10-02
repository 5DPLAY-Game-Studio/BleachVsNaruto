package net.play5d.kyo.display.ui
{
	public class KyoBtnGroup
	{
		private var _btns:Object;
		public function KyoBtnGroup(btns:Object)
		{
			_btns = btns;
		}
		
		public function focus(btn:IKyoButton):void{
			for each(var i:IKyoButton in _btns){
				if(i == btn) continue;
				i.focus = false;
			}
			btn.focus = true;
		}
		
	}
}