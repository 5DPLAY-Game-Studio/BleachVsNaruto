package net.play5d.kyo.input
{
	public class KyoKeyCode
	{
		public static const N0:KyoKeyVO = new KyoKeyVO('O',48);
		public static const N1:KyoKeyVO = new KyoKeyVO('1',49);
		public static const N2:KyoKeyVO = new KyoKeyVO('2',50);
		public static const N3:KyoKeyVO = new KyoKeyVO('3',51);
		public static const N4:KyoKeyVO = new KyoKeyVO('4',52);
		public static const N5:KyoKeyVO = new KyoKeyVO('5',53);
		public static const N6:KyoKeyVO = new KyoKeyVO('6',54);
		public static const N7:KyoKeyVO = new KyoKeyVO('7',55);
		public static const N8:KyoKeyVO = new KyoKeyVO('8',56);
		public static const N9:KyoKeyVO = new KyoKeyVO('9',57);
		
		public static const Num0:KyoKeyVO = new KyoKeyVO('Num0',96);
		public static const Num1:KyoKeyVO = new KyoKeyVO('Num1',97);
		public static const Num2:KyoKeyVO = new KyoKeyVO('Num2',98);
		public static const Num3:KyoKeyVO = new KyoKeyVO('Num3',99);
		public static const Num4:KyoKeyVO = new KyoKeyVO('Num4',100);
		public static const Num5:KyoKeyVO = new KyoKeyVO('Num5',101);
		public static const Num6:KyoKeyVO = new KyoKeyVO('Num6',102);
		public static const Num7:KyoKeyVO = new KyoKeyVO('Num7',103);
		public static const Num8:KyoKeyVO = new KyoKeyVO('Num8',104);
		public static const Num9:KyoKeyVO = new KyoKeyVO('Num9',105);
		
		public static const A:KyoKeyVO = new KyoKeyVO('A',65);
		public static const B:KyoKeyVO = new KyoKeyVO('B',66);
		public static const C:KyoKeyVO = new KyoKeyVO('C',67);
		public static const D:KyoKeyVO = new KyoKeyVO('D',68);
		public static const E:KyoKeyVO = new KyoKeyVO('E',69);
		public static const F:KyoKeyVO = new KyoKeyVO('F',70);
		public static const G:KyoKeyVO = new KyoKeyVO('G',71);
		public static const H:KyoKeyVO = new KyoKeyVO('H',72);
		public static const I:KyoKeyVO = new KyoKeyVO('I',73);
		public static const J:KyoKeyVO = new KyoKeyVO('J',74);
		public static const K:KyoKeyVO = new KyoKeyVO('K',75);
		public static const L:KyoKeyVO = new KyoKeyVO('L',76);
		public static const M:KyoKeyVO = new KyoKeyVO('M',77);
		public static const N:KyoKeyVO = new KyoKeyVO('N',78);
		public static const O:KyoKeyVO = new KyoKeyVO('O',79);
		public static const P:KyoKeyVO = new KyoKeyVO('P',80);
		public static const Q:KyoKeyVO = new KyoKeyVO('Q',81);
		public static const R:KyoKeyVO = new KyoKeyVO('R',82);
		public static const S:KyoKeyVO = new KyoKeyVO('S',83);
		public static const T:KyoKeyVO = new KyoKeyVO('T',84);
		public static const U:KyoKeyVO = new KyoKeyVO('U',85);
		public static const V:KyoKeyVO = new KyoKeyVO('V',86);
		public static const W:KyoKeyVO = new KyoKeyVO('W',87);
		public static const X:KyoKeyVO = new KyoKeyVO('X',88);
		public static const Y:KyoKeyVO = new KyoKeyVO('Y',89);
		public static const Z:KyoKeyVO = new KyoKeyVO('Z',90);
		
		public static const UP:KyoKeyVO = new KyoKeyVO('UP',38);
		public static const DOWN:KyoKeyVO = new KyoKeyVO('DOWN',40);
		public static const LEFT:KyoKeyVO = new KyoKeyVO('LEFT',37);
		public static const RIGHT:KyoKeyVO = new KyoKeyVO('RIGHT',39);
		
		public static const Delete:KyoKeyVO = new KyoKeyVO('DELETE',46);
		public static const End:KyoKeyVO = new KyoKeyVO('END',35);
		public static const PageDown:KyoKeyVO = new KyoKeyVO('PAGEDOWN',34);
		public static const PageUp:KyoKeyVO = new KyoKeyVO('PAGEUP',33);
		public static const Insert:KyoKeyVO = new KyoKeyVO('INSERT',45);
		public static const Home:KyoKeyVO = new KyoKeyVO('HOME',36);
		
		public static const SPACE:KyoKeyVO = new KyoKeyVO('SPACE',32);
		
		private static var _keyArray:Array = [N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,
											Num0,Num1,Num2,Num3,Num4,Num5,Num6,Num7,Num8,Num9,
											A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,
											UP,DOWN,LEFT,RIGHT,
											Delete,End,PageDown,PageUp,Insert,Home
										];
		
		public static function code2name(code:int):String{
			for each(var i:KyoKeyVO in _keyArray){
				if(i.code == code) return i.name;
			}
			return null;
		}
		
		public function KyoKeyCode()
		{
		}
	}
}