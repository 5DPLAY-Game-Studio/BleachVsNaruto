package net.play5d.game.bvn.mob.utils {
public class JsonUtils {
    public static function isJsonString(v:Object):Boolean {
        if (v is String) {
            var vs:String = v as String;
            return vs.charAt(0) == '{' || vs.charAt(0) == '[';
        }
        return false;
    }

    public static function str2json(v:Object):Object {
        if (isJsonString(v)) {
            var obj:Object;
            try {
                obj = JSON.parse(v as String);
            }
            catch (e:Error) {
                trace(e);
            }
            return obj;
        }
        return null;
    }

    public function JsonUtils() {
    }

}
}
