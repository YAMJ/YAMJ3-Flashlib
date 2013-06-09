import dent.Common;
import dent.tools.Util;
import dent.api.RemoteControl;

class dent.Dialog {
	public static var server_connecting:Boolean=false;

// ***************** SERVER CONNECT

	public static function server() {
		server_connecting=true;

		if(!Common.ready) {
			trace("Server Connect Message Skipped, not ready");
			return;
		}

		if(Util.notfound(Common.stage.connect)) {
			trace("Displaying connection to server message");
			dim('CONNECTDIM');
			Common.stage.attachMovie("connectMC", "conn", Common.depths['CONNECT'], {_x:338, _y:310});
		}
	}

	public static function server_remote(keyhit) {
		if(!Common.ready) return;
		trace("server remote: "+keyhit);

		// TODO: not sure yet
	}

	public static function server_clear() {
		server_connecting=false;

		trace("clearing server message");

		Common.stage.conn.removeMovieClip();
		Common.stage.CONNECTDIM.removeMovieClip();
	}

	private static function dim(clipname) {

		if(clipname != 'DIM' && clipname !='CONNECTDIM') return;

		if(Util.notfound(Common.stage[clipname])) {
			trace("dimming "+clipname);
			var d:MovieClip=Common.stage.createEmptyMovieClip(clipname, Common.depths[clipname]);

			d.beginFill(0x000000,60);
			d.lineTo(1280,0);
			d.lineTo(1280,720);
			d.lineTo(0,720);
			d.lineTo(0,0);
			d.endFill();
		}
	}

// ***************** FATAL

	public static function fatal(message) {
		trace("fatal message "+message);

		var errorMC:MovieClip = Common.stage.attachMovie("fatalMC", "fatalMC", Common.stage.getNextHighestDepth(), {_x:325, _y:290});
		errorMC.message_txt.text=message;

		Common.runtime.halt=true;
		RemoteControl.stop_remote();
	}

// ***************** POPUP/error
	public static function popup(message, header, prompt) {
		trace("pop message "+message);

		if(!Util.notfound(Common.stage.popup)) {
			trace("popup already on screen,skipped");
			return;
		}

		dim('DIM');
		Common.stage.attachMovie("popupMC", "popup", Common.depths['POPUP'], {_x:325, _y:290});
		Common.stage.popup.message_txt.text=message;

		if(!Util.unknown(prompt)) {
			Common.stage.popup.prompt_txt.text=prompt;
		}

		if(!Util.unknown(header)) {
			Common.stage.popup.header_txt.text=header;
		}

		RemoteControl.popup=true;
	}

	public static function error(message, header, prompt) {
		trace("error message "+message);

		if(!Util.notfound(Common.stage.error)) {
			trace("error already on screen,skipped");
			return;
		}

		Common.stage.attachMovie("errorMC", "error", Common.depths['ERROR'], {_x:325, _y:290});
		Common.stage.error.message_txt.text=message;

		if(!Util.unknown(prompt)) {
			Common.stage.error.prompt_txt.text=prompt;
		}

		if(!Util.unknown(header)) {
			Common.stage.error.header_txt.text=header;
		}

		RemoteControl.popup=true;
	}

	public static function dialog_remote(keyhit) {
		trace("dialog remote, closing popups");

		Common.stage.popup.removeMovieClip();
		Common.stage.error.removeMovieClip();
		Common.stage.DIM.removeMovieClip();

		RemoteControl.popup=false;
	}

// ***************** SPLASH

	public static function splash(message) {
		// TODO: make sure splash isn't up already
		Common.stage.attachMovie("splashMC", "splashMC", Common.stage.getNextHighestDepth(), {_x:0, _y:0});
		trace('splash visible');

		Dialog.update_splash(message);
	}

	public static function close_splash() {
		Common.stage.splashMC.removeMovieClip();
		trace("splash removed");
	}

	public static function update_splash(message) {
		if(message==undefined) {
			Common.stage.splashMC.removeMovieClip();
			trace("splash removed");
		} else {
			trace("splash message "+message);

			Common.stage.splashMC.message_txt.text=message;
		}
	}

	public static function debug_splash(message) {
		if(Common.runtime.debug=='true') {
			Common.stage.splashMC.debug_txt.text=message;
		}
	}

// **************** PRELOADER

	public static function preload(message) {
		if(Util.unknown(message)) {
			trace("preloader skipped, bad message: "+message);
			return;
		}

		// add preloader if not on
		if(Util.notfound(Common.stage.preload)) {
			Common.stage.attachMovie("preloader", "preload", Common.depths['PRELOADER'], {_x:32, _y:50});

			// TODO: future animation setting
			_global["setTimeout"](Dialog.preload_animate, 1000);
		}

		// add message
		Common.stage.preload.preload_txt.text=message;

		trace("Preloader updated: "+message);
	}

	public static function preload_animate() {
		if(!Util.notfound(Common.stage.preload)) {
			trace("preloader now animating");
			Common.stage.preload.circle.gotoAndPlay(2);
		} //else preload_clear();
	}

	public static function preload_clear() {
		trace("Preloader cleared");
		Common.stage.preload._visible=false;
		Common.stage.preload.circle.stop();
		Common.stage.preload.removeMovieClip();
	}
}
