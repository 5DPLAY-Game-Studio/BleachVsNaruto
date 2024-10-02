package net.eidiot.map
{
	/**
	 * 地图模型接口
	 * 
	 * @author eidiot (http://eidiot.net)
	 * @version	1.0
	 * @date	070416
	 */	
	public interface IMapTileModel
	{
		/**
		 * 是否为障碍
		 * @param p_startX	始点X坐标
		 * @param p_startY	始点Y坐标
		 * @param p_endX	终点X坐标
		 * @param p_endY	终点Y坐标
		 * @return			0为障碍 1为通路
		 */
		function isBlock(p_startX : int, p_startY : int, p_endX : int, p_endY : int) : int;
	}
}