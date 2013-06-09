// This file is part of YAMJ3-Flashlib.

// YAMJ3-Flashlib is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// YAMJ3-Flashlib is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with YAMJ3-Flashlib.  If not, see <http://www.gnu.org/licenses/>.

import dent.Common;
import dent.Dialog;
import dent.tools.Data;
import dent.tools.UltraLoader;
import dent.tools.StringUtil;
import dent.tools.Util;
import dent.api.Control;
import dent.api.Hardware;
import dent.api.RemoteControl;
import dent.api.YAMJ;

class dent.api.Server {
// ************ CONNECT
	public static function first_connect(callback) {
		Dialog.update_splash('Connecting to YAMJ Server');
		Server.connect(callback);
	}

	public static function first_socket(callback) {
		Control.start_socket(callback);
	}

	public static function connect(callback) {
		trace('connecting to yamj server');
		Server.get(Common.runtime.server['yamjshort']+"system/info", Server.setupserver, callback);
	}

	public static function setupserver(success, data, callback) {
		if(success) {
			trace(data);
			if(StringUtil.beginsWith(data.moduleName, "YAMJ")) {
				trace("YAMJ SERVER!!!");

				// load everything up
				Dialog.update_splash('Loading data from YAMJ');
				YAMJ.load_all(Server.setupdone, callback);
			} else {
				trace("Not a YAMJ Server");
				callback(false);
			}
		} else {
			trace("Not a YAMJ Server");
			callback(false);
		}
	}

	public static function setupdone(callback) {
		callback(true);
	}


// ************ FIND/SETUP SERVER CONFIG
	public static function find(callback) {
		trace('figuring out my server');

		trace('.. debug.xml');
		Data.fastXMLArray(Common.runtime.runpath+'/debug.xml',Server.after_debug, callback);
	}

	public static function after_debug(success,vars,errorcode,callback) {
		if(success) {
			if(Server.process_serverconfig(vars)) {
				callback(true);
			} else {
				trace('.. yamj.xml');
				Data.fastXMLArray(Common.runtime.runpath+'/yamj.xml',Server.after_dent, callback);
			}
		} else {
			trace("... bad "+errorcode);
			trace('.. yamj.xml');
			Data.fastXMLArray(Common.runtime.runpath+'/yamj.xml',Server.after_dent, callback);
		}
	}

	public static function after_dent(success,vars,errorcode,callback) {
		if(success && Server.process_serverconfig(vars)) {
			callback(true);
		} else {
			// TODO: hardware passed settings (via args or api data)
			//Hardware.find_server(callback);
			callback(false);
		}
	}

	public static function process_serverconfig(vars) {
		if(Common.runtime.player==undefined) {
			Common.runtime.player=vars.player;
			trace(".. hardware player: "+vars.player);
		}

		if(vars.skipplayer == "true") {
			Common.runtime.skipplayer=true;
			trace(".. player detect disabled");
		} else trace(".. player detect enabled");

		if(Common.runtime.server['yamj']==undefined) {
			if(vars.server != undefined) {
				Common.runtime.server['yamj']="http://"+vars.server+"/yamj3/api/";
				Common.runtime.server['yamjshort']="http://"+vars.server+"/yamj3/";
				var temp=vars.server.split(':');
				Common.runtime.server['serverhost']=temp[0];
				Common.runtime.server['serverport']=Number(temp[1]);
				trace(".. yamj server: "+Common.runtime.server['serverhost']);
				trace(".. yamj port: "+Common.runtime.server['serverport']);
				trace(".. yamj api: "+Common.runtime.server['yamj']);
				trace(".. yamj root: "+Common.runtime.server['yamjshort']);
				return true;
			}
		}
		trace("... no server in config ");
		return false;
	}

// ************ ON DEMAND CALLS
	public static function retrieve(from, finalcallback) {
		trace("server call: "+from);
		Server.get(from, Server.capi_data, finalcallback);
	}

	public static function capi_data(success, data, finalcallback, from) {
		if(success) {
			if(data['status']) {
				finalcallback(true, data['data'], data['message']);
			} else {
				finalcallback(false, null, data['message']);
			}
		} else {
			trace("bad load for "+from);
			finalcallback(false, null, "failed to load: "+from);
		}
	}

	public static function get(command, callback, finalcallback) {
		UltraLoader.json(Util.fix_url(command), null, 2, callback, finalcallback);
	}

}
