package net.play5d.game.bvn.mob.ctrls {
import com.adobe.crypto.MD5;

import flash.filesystem.File;

import net.play5d.game.bvn.mob.data.AdConfVO;
import net.play5d.game.bvn.mob.data.VersionInfoVO;
import net.play5d.game.bvn.mob.utils.FileUtils;
import net.play5d.kyo.loader.KyoURLoader;

public class GamePolyCtrl {

    private static var _i:GamePolyCtrl;

    public static function get I():GamePolyCtrl {
        _i ||= new GamePolyCtrl();
        return _i;
    }

    public function GamePolyCtrl() {
    }
    private var _versionInfo:VersionInfoVO;
    private var _adConfList:Vector.<AdConfVO>;

    public function getVersion():VersionInfoVO {
        return _versionInfo;
    }

    public function getAdConf():Vector.<AdConfVO> {
        return _adConfList;
    }

    public function loadConfig(urls:Array, back:Function):void {
        loadNext();

        function loadNext():void {
            if (urls.length < 1) {
                readLocalConfig();
                if (back != null) {
                    back();
                }
                return;
            }

            var url:String = urls.shift();
            url += '?rand=' + int(Math.random() * 10000);
            trace('request::' + url);

            KyoURLoader.load(url, function (data:String):void {
                if (!parseConfig(data)) {
                    loadNext();
                    return;
                }

                saveLocalConfig(data);
                if (back != null) {
                    back();
                }
            }, loadNext);
        }
    }

    private function parseConfig(data:String):Boolean {
        if (!data || data.length < 1) {
            return false;
        }

        var arr:Array = data.split('|');
        if (arr.length != 2) {
            return false;
        }

        var json:String = arr[0];
        var hash:String = arr[1];
        try {
            if (MD5.hash('$%_ST_%$' + json + '$%_ED_%$') != hash) {
                return false;
            }

            var o:Object  = JSON.parse(json);
            var vs:Object = o.VS;
            if (vs) {
                _versionInfo             = new VersionInfoVO();
                _versionInfo.version     = vs.V;
                _versionInfo.url         = vs.U;
                _versionInfo.info        = vs.I;
                _versionInfo.forceUpdate = vs.F;
                _versionInfo.enabled     = vs.E;

            }

            var ad:Array = o.AD;
            if (ad) {
                _adConfList = new Vector.<AdConfVO>;

                for (var i:int = 0; i < ad.length; i++) {
                    var ado:Object = ad[i];

                    var acvo:AdConfVO = new AdConfVO();
                    acvo.code         = ado.C;
                    acvo.rank         = ado.P;
                    acvo.rate         = ado.R;
                    acvo.enabled      = ado.E;

                    _adConfList.push(acvo);
                }
            }

            return true;
        }
        catch (e:Error) {
            trace('GamePolyCtrl.parseConfig', e);
            return false;
        }

        return false;
    }

    private function saveLocalConfig(json:String):void {
        var f:File = File.applicationStorageDirectory.resolvePath('bvnpoly.conf');
        FileUtils.writeFile(f.nativePath, json);
    }

    private function readLocalConfig():void {
        var f:File      = File.applicationStorageDirectory.resolvePath("bvnpoly.conf");
        var data:String = FileUtils.readTextFile(f.nativePath);

        parseConfig(data);
    }
}
}
