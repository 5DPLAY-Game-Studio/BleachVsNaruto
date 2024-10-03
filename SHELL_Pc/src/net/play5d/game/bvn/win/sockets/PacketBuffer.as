package net.play5d.game.bvn.win.sockets
{
	import flash.utils.ByteArray;
	
	public class PacketBuffer  
	{  
		private var buf:ByteArray = new ByteArray();  
		public function PacketBuffer()  
		{
		}
		public function push(ba:ByteArray):void  
		{  
			if(buf == null)  
			{  
				buf = ba;  
			}else  
			{  
				buf.position = buf.length;  
				buf.writeBytes(ba);  
			}  
		}  
		public function getPackets():Array  
		{  
			var ps:Array = [];  
			buf.position = 0;  
			while(buf.bytesAvailable >= 2)  //这里是说当可用数据大于包头时，一个包==包头(body的长度)+包体(body)，也就是说包里如果一旦有数据就开始执行  
			{                                //2其实是readShort()后，少了的2个字节，也就是body有数据的时候才开始解码  
				var len:uint = buf.readShort();  
				//不足一个包，这里完全有可能，当只读取完包头len，但是body却没有读取到末尾  
				if(buf.bytesAvailable < len)  
				{  
					var ba:ByteArray = new ByteArray();
					ba.writeBytes(buf, 0, buf.bytesAvailable);            
					buf = ba;         
					//返回  
					return ps;  
				}  
//				buf.position += 2;
				var mb:ByteArray = new ByteArray();  
				buf.readBytes(mb, 0, len);   //len为body的长度，将body的数据放入mb  
				mb.position = 0;  
				
				ps.push(mb);
				/*
				var data:Object = mb.readObject();
//				buf.position=0;
				ps.push(data);  //放入数组  
				*/
				//下一个包  while语句进行下一个循环  
			}  
			if(buf.bytesAvailable <= 0)buf = null;  
			return ps;  
		}  
		public function clear():void  
		{  
			buf=null;  
		}  
	}  
	
	
	
}