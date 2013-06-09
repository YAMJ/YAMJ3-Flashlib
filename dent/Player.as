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
import mx.utils.Delegate;

class dent.Player {
	private static var playMC:MovieClip=null;
	private static var ready:Boolean=false;

	// state
	public static var isPlaying:Boolean=false;

	public static function init() {
		if(!ready) {
			cleanup();
			reset();

			trace("Player init");
		} else {
			trace("Player init skipped, ready");
		}
	}

	private static function reset() {
		playMC.removeMovieClip();
		isPlaying=false;
		ready=true;

		// todo: add clip at depth
	}

	public static function remote(keyhit, keyname, full) {
		trace("player remote hit full: "+full);

		if(isPlaying) {
			trace("isplaying, remote");
			if(full) {  // called last
				// buttons not needed for mininav processed here
				trace("full button check");
			} else {    // called first
				// buttons that always work here
				trace("partial button check");
			}

			// ???? not sure about volume and page up/down.  might need to be a device behavior
		} else {
			trace("skipped, not playing");

		}
	}

	public static function cleanup() {
		playMC.removeMovieClip();
		isPlaying=false;
	}
}


