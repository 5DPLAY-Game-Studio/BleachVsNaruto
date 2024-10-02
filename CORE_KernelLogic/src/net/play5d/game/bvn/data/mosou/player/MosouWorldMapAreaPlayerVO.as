package net.play5d.game.bvn.data.mosou.player
{
	import net.play5d.game.bvn.data.ISaveData;
	
	public class MosouWorldMapAreaPlayerVO implements ISaveData
	{
		public var id:String;
		public var name:String;
		
//		public var missions:Vector.<MosouMissionPlayerVO> = new Vector.<MosouMissionPlayerVO>();
		
		private var _passedMissions:Vector.<MosouMissionPlayerVO> = new Vector.<MosouMissionPlayerVO>();
		
//		public var isOpen:Boolean;
		
		public function MosouWorldMapAreaPlayerVO()
		{
		}
		
		public function passMission(missionId:String, starts:int = 1):Boolean{
			var isNewPassed:Boolean = false;
			
			var mv:MosouMissionPlayerVO = getPassedMission(missionId);
			if(!mv){
				isNewPassed = true;
				mv = new MosouMissionPlayerVO();
				mv.id = missionId;
				_passedMissions.push(mv);
			}
			
			mv.stars = starts;
			
			return isNewPassed;
		}
		
		
		public function getPassedMission(id:String):MosouMissionPlayerVO{
			for(var i:int; i < _passedMissions.length; i++){
				if(_passedMissions[i].id == id) return _passedMissions[i];
			}
			return null;
		}
		
		public function getLastPassedMission():MosouMissionPlayerVO{
			if(_passedMissions.length < 1) return null;
			return _passedMissions[_passedMissions.length - 1];
		}
		
		public function getPassedMissionAmount():int{
			return _passedMissions.length;
		}
		
		public function toSaveObj():Object
		{
			var o:Object = {};
			o.id = id;
			o.name = name;
			
			o.missions = [];
			for(var i:int; i < _passedMissions.length; i++){
				o.missions.push(_passedMissions[i].toSaveObj());
			}
			return o;
		}
		
		public function readSaveObj(o:Object):void
		{
			id = o.id;
			name = o.name;
			
			_passedMissions = new Vector.<MosouMissionPlayerVO>();
			if(o.missions){
				for(var i:int; i < o.missions.length; i++){
					var mv:MosouMissionPlayerVO = new MosouMissionPlayerVO();
					mv.readSaveObj(o.missions[i]);
					_passedMissions.push(mv);
				}
			}
			
		}
	}
}