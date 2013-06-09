import dent.Common;
import dent.tools.StringUtil;

class dent.tools.Util {
	// from: http://www.actionscript.org/forums/showthread.php3?t=228892

	public function merge(t:Object, s:Object) {
		for(var p:String in s) {
			t[p] = s[p];
		}
	}

	public static function notfound(check) {
		if(check==undefined || check==null) {
			return true;
		}
		return false;
	}

	public static function empty(check) {
		if(check==undefined || check==null || check.length<1) {
			return true;
		}
		return false;
	}

	public static function blank(check) {
		if(check==undefined || check==null || check=='' || check=='\n' || check=='\r' || check=='\n\r' || check=='\r\n') {
			return true;
		}
		return false;
	}

	public static function unknown(check) {
		if(check==undefined || check==null || check=='' || check=='\n' || check=='\r' || check=='\n\r' || check=='\r\n' || check=='unknown' || check=='UNKNOWN') {
			return true;
		}
		return false;
	}

	public static function truefalse(check, norm:Boolean) {
		if(check==false || check=="false" || check=="0" || check=="off") {
			return(false);
		} else if(check==true || check=="true" || check=="1" || check=="on") {
			return(true);
		} else return(norm);
	}

	public static function fix_url(url) {
		if(!StringUtil.beginsWith(url, "http://") && !StringUtil.beginsWith(url, "file://")) {
			return Common.runtime.server['yamj']+url;
		}
		return url;
	}
}