import dent.Common;
import dent.Dialog;
import dent.tools.Data;
import dent.api.Playerapi;
import mx.utils.Delegate;

// players supported
import dent.api.players.Syabas;
import dent.api.players.Dune;

// class for figure out what api profile to use

class dent.api.Hardware {
	public static var callback:Function=null;
	public static var setupcallback:Function=null;
	public static var detect_current=null;
	public static var detect_list:Array=null;

	public static function find_server(callback) {
		Hardware.setupcallback=callback;
		Hardware.setupapi(Hardware.find_server_apiready);
	}

	public static function find_server_apiready() {
		trace('checking for dent server via hardware');
		Common.playerapi.find_server(Hardware.setupcallback);
	}

	public static function setupapi(callback) {
		if(Common.playerapi!=null) {
			trace("setup api skipped, already established");
			callback();
		}

		trace('setting up api');
		Dialog.update_splash('Detecting player hardware');
		Hardware.callback=callback;

		if(!Common.runtime.skipplayer) {
			if(fscommand2("GetDevice", "device") != -1) {
				trace('device from flash: '+_root.device);
				Dialog.debug_splash(_root.device);

				switch(_root.device) {
					case 'noclue':  // need to run from some players and check debug for what they are
						break;
					default:
						Hardware.check_apis();
						return;
				}
			} else {
				Hardware.check_apis();
				return;
			}
		} else {
			trace("player detect skipped by settings");

			Common.playerapi=new Playerapi();
			Hardware.callback();
		}
	}

	public static function check_apis() {
		Hardware.detect_list=new Array();

		// put them in reverse order we want to check
		Hardware.detect_list.push(new Syabas());
		Hardware.detect_list.push(new Dune());

		// loop them
		Hardware.after_apicheck(false);
	}

	public static function after_apicheck(success) {
		if(!success) {
			if(Hardware.detect_list.length>0) {
				Hardware.detect_current=Hardware.detect_list.pop();
				Hardware.detect_current.detect(Hardware.after_apicheck);
			} else {
				// use generic
				Common.playerapi=new Playerapi();
				Hardware.callback();
			}
		} else {
			Common.playerapi=Hardware.detect_current;
			Hardware.callback();
		}
	}
}