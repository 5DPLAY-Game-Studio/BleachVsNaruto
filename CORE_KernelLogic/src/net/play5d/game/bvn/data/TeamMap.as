package net.play5d.game.bvn.data
{
	public class TeamMap
	{
		public var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
		private var _teamObj:Object = {};
		public function TeamMap()
		{
		}
		
		public function clear():void{
			_teamObj = {};
		}
		
		public function getTeam(id:int):TeamVO{
			return _teamObj[id];
		}
		
		public function getOtherTeams(id:int):Vector.<TeamVO>{
			var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
			for each(var i:TeamVO in _teamObj){
				if(i.id != id) teams.push(i);
			}
			return teams;
		}
		
		public function add(v:TeamVO):void{
			_teamObj[v.id] = v;
			refreshTeams();
		}
		
		public function remove(v:TeamVO):void{
			delete _teamObj[v.id];
			refreshTeams();
		}
		
		private function refreshTeams():void{
			teams = new Vector.<TeamVO>();
			for each(var i:TeamVO in _teamObj){
				if(i) teams.push(i);
			}
		}
		
	}
}