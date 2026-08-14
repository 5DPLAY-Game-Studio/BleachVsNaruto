package net.play5d.game.bvn.mob.ctrls {
import com.adobe.crypto.MD5;

import flash.filesystem.File;

import net.play5d.game.bvn.mob.data.VersionInfoVO;
import net.play5d.kyo.air.utils.FileUtils;
import net.play5d.kyo.loader.KyoURLLoader;

public class GamePolyCtrl {

    private static var _i:GamePolyCtrl;

    public static function get I():GamePolyCtrl {
        _i ||= new GamePolyCtrl();
        return _i;
    }

    private var _versionInfo:VersionInfoVO;

    public function getVersion():VersionInfoVO {
        return _versionInfo;
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

            KyoURLLoader.load(url, function (data:String):void {
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
        var f:File      = File.applicationStorageDirectory.resolvePath('bvnpoly.conf');
        var data:String = FileUtils.readTextFile(f.nativePath);

        parseConfig(data);
    }
}
}
