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


