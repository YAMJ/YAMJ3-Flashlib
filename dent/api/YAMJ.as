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
import dent.tools.StringUtil;
import dent.tools.Util;
import dent.api.Server;

class dent.api.YAMJ {
	public static var all_cb:Function=null;
	public static var all_pt:Function=null;

// ************** quick loads
	public static function load_all_blind() {
	    // blind first load call to get all the data

		YAMJ.load_genres();
		YAMJ.load_studios();
		YAMJ.load_certifications();
	}

	public static function load_all(callback, passthrough) {
		YAMJ.all_cb=callback;
		YAMJ.all_pt=passthrough;

		YAMJ.load_genres(YAMJ.studionext);
	}

	public static function studionext() {
		YAMJ.load_studios(YAMJ.certnext);
	}

	public static function certnext() {
		YAMJ.load_certifications();

		// done
		YAMJ.all_cb(YAMJ.all_pt);
	}



// ************** GENRES

	public static function load_genres(callback) {
		trace("loading genre list");

		Server.get("genres",YAMJ.process_genres, callback);
	}

	public static function process_genres(success, data, callback) {
		if(success) {

			delete Common.genres;
			Common.genres=new Object();

			if(data.count > 0) {
				for(var t in data.results) {
					Common.genres[data.results[t].id] = data.results[t].name;
				}

				trace("new genres list");
				trace(Common.genres);
			} else {
				trace("no genres");
			}

			callback(true);
		} else {
			trace("problem loading genres");
			callback(false);
		}
	}

// ************** STUDIOS

	public static function load_studios(callback) {
		trace("loading studio list");

		Server.get("studios",YAMJ.process_studios, callback);
	}

	public static function process_studios(success, data, callback) {
		if(success) {

			delete Common.studios;
			Common.studios=new Object();

			if(data.count > 0) {
				for(var t in data.results) {
					Common.studios[data.results[t].id] = data.results[t].name;
				}

				trace("new studios list");
				trace(Common.studios);
			} else {
				trace("no studios");
			}

			callback(true);
		} else {
			trace("problem loading studios");
			callback(false);
		}
	}

// ************** CERTIFICATIONS

	public static function load_certifications(callback) {
		trace("loading certifications list");

		Server.get("certifications",YAMJ.process_certifications, callback);
	}

	public static function process_certifications(success, data, callback) {
		if(success) {
			delete Common.certifications;
			Common.certifications=new Object();

			if(data.count > 0) {
				for(var t in data.results) {
					Common.certifications[data.results[t].id] = data.results[t].name;
				}

				trace("new certifications list");
				trace(Common.certifications);
			} else {
				trace("no certifications");
			}

			callback(true);
		} else {
			trace("problem loading certifications");
			callback(false);
		}
	}
}
