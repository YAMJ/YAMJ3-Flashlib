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

import mx.utils.Delegate;

class dent.History {
	public static var history:Array=null;         	// history list
	public static var where:Number=null;			// where in the list we are

	// check and init if needed
	private static function check() {
		if (where==null) clear();
	}

	// init/clear the history, setup home as start
	private static function clear() {
		trace("clearing history");

		delete history;
		history=new Array();
		where=0;

		history[0]=def('nav/home');
		trace(history[0].url);
	}

	public static function len() {
		return where+1;
	}

	private static function def(url) {
		// make a default history record

		return {url:url,state:null};
	}

	public static function current() {
		check();

		return (history[where]);
	}

	private static function trim() {
		var to:Number=where+1;
		while(to < history.length) {
			trace("removing end of history");
			history.pop();
		}

		while (history.length>50) {
			trace("history over 50, trimming");
			history.shift();
			where--;
		}
	}

	public static function next(url) {
		if(check_url(url)) {
			where++;
			history[where]=def(url);

			trim();

			return history[where];
		}

		return null;
	}

	public static function back() {
		if(where<1) {
			if(history[0].url!='nav/home') {
				trace("history: no more back, resetting to home");
				clear();
				return history[where];
			} else {
				trace("history: no more back, staying at home");
				return null;
			}
		}

		where--;
		return history[where];
	}

	public static function forward() {
		if(where==history.length) {
			trace("skipped forward: we're at the end");
			return null;
		}

		where++;
		return history[where];
	}

	public static function move(how) {
		trace("history move "+how);
		switch(how.toUpperCase()) {
			case 'BACK':
				return back();
			case 'FORWARD':
				return forward();
			case 'HOME':
				return next('home');
			default:
				trace(".. not added yet");
		}
		return null;
	}

	public static function check_url(url) {
		if(history[where].url==url) {
			trace("... skipped: same url");
			return false;
		}
		return true;
	}

	public static function add_state(state) {
		trace("history updated state for "+history[where].url);
		history[where].state=state.clone();
	}
}
