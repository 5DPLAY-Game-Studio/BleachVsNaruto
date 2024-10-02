package net.play5d.game.bvn.ui.mosou
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.GameRunFighterGroup;
	import net.play5d.game.bvn.fighter.FighterMain;

	public class MosouFightBarUI
	{
		private var _ui:mosou_hpbar_mc;
		private var _face:mosou_hpbar_facemc;
		
		private var _hpbar:MosouHpBar;
		private var _qibar:MosouQiBar;
		
		private var _energybar:MosouEnergyBar;
		
		private var _littleHpBar1:LittleHpBar;
		private var _littleHpBar2:LittleHpBar;
		
		private var _group:GameRunFighterGroup;
		
		public function MosouFightBarUI(ui:mosou_hpbar_mc)
		{
			_ui = ui;
			
			_hpbar = new MosouHpBar(ui.hpbar, ui.hpbar2);
			_qibar = new MosouQiBar(ui.qibar);
			
			_energybar = new MosouEnergyBar(ui.energybar);
			
			_littleHpBar1 = new LittleHpBar(ui.little_hp_1);
			_littleHpBar2 = new LittleHpBar(ui.little_hp_2);
			
			_face = ui.facemc;
		}
		
		public function setFighter(group:GameRunFighterGroup):void{
			_group = group;
			updateFighters();
		}
		
		public function updateFighters():void{
			_hpbar.setFighter(_group.currentFighter);
			_qibar.setFighter(_group.currentFighter);
			_energybar.setFighter(_group.currentFighter);
			updateFace();
			
			var fighters:Vector.<FighterVO> = _group.getFighters(true);
			
			var fighter1:FighterMain = _group.getFighter(fighters[0]);
			var fighter2:FighterMain = _group.getFighter(fighters[1]);
			
			_littleHpBar1.setFighter(fighter1);
			_littleHpBar2.setFighter(fighter2);
		}
		
		private function updateFace():void{
			var ct:Sprite = _face.getChildByName('ct') as Sprite;
			if(ct){
				var faceImg:DisplayObject = AssetManager.I.getFighterFaceBar(_group.currentFighter.data);
				if(faceImg){
					ct.removeChildren();
					ct.addChild(faceImg);
				}
			}
			
		}
		
		public function render():void
		{
			_hpbar.render();
			_qibar.render();
			_energybar.render();
		}
		
		public function renderAnimate():void{
			_littleHpBar1.renderAnimate();
			_littleHpBar2.renderAnimate();
		}
		
		
	}
}