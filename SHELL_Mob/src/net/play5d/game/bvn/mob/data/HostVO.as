package net.play5d.game.bvn.mob.data {
import flash.utils.ByteArray;

public class HostVO {

    public function HostVO() {
    }
//		public var tcpPort:int;
//		public var udpPort:int;
    public var ip:String;
    public var ownerName:String;
    public var gameMode:int = 1;
    public var hp:int       = 1;
    public var gameTime:int = 60;

    public function toJson():String {
        var o:Object = {
            ownerName: ownerName,
            gameMode : gameMode,
            hp       : hp,
            gameTime : gameTime
        };
        var s:String = JSON.stringify(o);
        return s;
    }

    public function readJson(json:String):void {
        var o:Object = JSON.parse(json);
        ownerName    = o.ownerName;
        gameMode     = o.gameMode;
        hp           = o.hp;
        gameTime     = o.gameTime;
    }

    public function toByteArray():ByteArray {

        var byte:ByteArray = new ByteArray();
        byte.writeByte(gameMode);
        byte.writeByte(gameTime);
        byte.writeByte(hp);
        return byte;
    }

    public function readByteArray(byte:ByteArray):void {
        gameMode = byte.readByte();
        gameTime = byte.readByte();
        hp       = byte.readByte();
    }

    public function getGameModeStr():String {
        switch (gameMode) {
        case 1:
            return 'TEAM VS - 小队对战';
            break;
        case 2:
            return 'SINGLE VS - 单人对战';
            break;
        }
        return null;
    }

}
}
