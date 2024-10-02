package net.play5d.game.bvn.ui.select
{
	import net.play5d.game.bvn.data.AssisterModel;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.FighterVO;
	import net.play5d.game.bvn.data.SelectVO;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.utils.KyoRandom;
	import net.play5d.kyo.utils.KyoUtils;

	public class SelecterItemUI
	{
		public var ui:select_item_mc;
		
		public var currentFighter:FighterVO;
		
		public var selectTimes:int;
		public var selectTimesCount:int = 1;
		
		public var inputType:String;
		
		public var group:SelectedFighterGroup;
		
		public var selectVO:SelectVO;
		
		public var isSelectAssist:Boolean;
		
		public var x:int;
		public var y:int;
		
		public var moreX:int = 0;
		public var moreY:int = 0;
		private var _moreEnable:Boolean = false;
		public var showingMoreSelecter:SelectFighterItem;
		
		public var enabled:Boolean = true;
		
		public var randoms:Vector.<FighterVO> = null;
		public var randFrame:int;
		
		public var touchHoverItem:SelectFighterItem;
		
		private var _playerType:int;
		
		public function SelecterItemUI(playerType:int = 1)
		{
			_playerType = playerType;
			ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.select , 'select_item_mc');
			ui.mouseEnabled = ui.mouseChildren = false;
			ui.mc.gotoAndStop(playerType == 1 ? 1 : 2);
		}
		
		/**
		 * 是否选择完成 
		 */
		public function selectFinish():Boolean{
			return selectTimes >= selectTimesCount;
		}
		
		public function getCurrentSelectes():Array{
			if(isSelectAssist){
				return [selectVO.fuzhu];
			}else{
				return [selectVO.fighter1 , selectVO.fighter2 , selectVO.fighter3];
			}
		}
		
		public function setCurrentSelect(v:Array):void{
			if(isSelectAssist){
				selectVO.fuzhu = v[0];
				
				group.updateFighter(AssisterModel.I.getAssister(selectVO.fuzhu));
				
			}else{
				selectVO.fighter1 = v[0];
				selectVO.fighter2 = v[1];
				selectVO.fighter3 = v[2];
				
				group.updateFighter(FighterModel.I.getFighter(selectVO.fighter1));
				group.addFighter(FighterModel.I.getFighter(selectVO.fighter2));
				group.addFighter(FighterModel.I.getFighter(selectVO.fighter3));
				
			}
			
			selectTimes = selectTimesCount;
			
			enabled = false;
			
		}
		
		public function moreEnabled():Boolean{
			return _moreEnable;
		}
		
		public function setMoreEnabled(enab:Boolean, curSelecter:SelectFighterItem = null):void{
			_moreEnable = enab;
			
			if(enab){
				this.moreX = 0;
				this.moreY = 0;
				if(!curSelecter){
					throw Error("Need SelectFighterItem !!");
				}
				this.showingMoreSelecter = curSelecter;
				if(this.showingMoreSelecter) this.showingMoreSelecter.setMoreNumberVisible(false);
			}else{
				if(this.showingMoreSelecter) this.showingMoreSelecter.setMoreNumberVisible(true);
				this.showingMoreSelecter = null;
			}
			
		}
		
		/**
		 * 是否已经选过该角色
		 */
		public function isSelected(id:String):Boolean{
			if(!selectVO) return false;
			if(isSelectAssist) return selectVO.fuzhu == id;
			return selectVO.fighter1 == id || selectVO.fighter2 == id || selectVO.fighter3 == id;
		}
		
		public function select(back:Function = null):void{
			
			if(!selectVO){
				throw new Error("未设置selectVO!");
				return;
			}
			
//			trace('P'+_playerType+"::",currentFighter.id);
			
//			if(randoms) currentFighter = KyoRandom.getRandomInArray(randoms, false);
			
			if(isSelectAssist){
				selectVO.fuzhu = currentFighter.id;
			}else{
				switch(selectTimes){
					case 0:
						selectVO.fighter1 = currentFighter.id;
						break;
					case 1:
						selectVO.fighter2 = currentFighter.id;
						break;
					case 2:
						selectVO.fighter3 = currentFighter.id;
						break;
				}
			}
			
			selectTimes++;
			
			if(!selectFinish()){
				group.addFighter(currentFighter);
			}
			
			enabled = false;
			
			var _this:* = this;
			
			ui.gotoAndPlay("select");
			
			updateRandom();
			
			KyoUtils.addFrameScript(ui,function():void{
				if(!selectFinish()) enabled = true;
				if(back != null) back(_this);
			});
			
		}
		
		public function moveTo(x:Number , y:Number):void{
			ui.x = x;
			ui.y = y;
		}
		
		public function destory():void{
			enabled = false;
			removeSelecter();
			removeGroup();
		}
		
		public function removeSelecter():void{
			if(ui && ui.parent){
				try{
					ui.parent.removeChild(ui);
				}catch(e:Error){}
				ui = null;
			}
		}
		
		public function removeGroup():void{
			if(group && group.parent){
				try{
					group.parent.removeChild(group);
				}catch(e:Error){}
				group = null;
			}
		}
		
		private function updateRandom():void{
			if(!randoms) return;
			if(!selectVO) return;
			
			selectVO.fighter1 && removeRand(selectVO.fighter1);
			selectVO.fighter2 && removeRand(selectVO.fighter2);
			selectVO.fighter3 && removeRand(selectVO.fighter3);
		}
		
		private function removeRand(id:String):void{
			var index:int = -1;
			for(var i:int ; i < randoms.length; i++){
				if(randoms[i].id == id){
					index = i;
					break;
				}
			}
			
			if(index != -1) randoms.splice(index, 1);
			
		}
		
	}
}