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
import dent.tools.Util;
import dent.tools.StringUtil;
import mx.utils.Delegate;
import com.adobe.stagecraft.FastJSON;
import com.designvox.tranniec.JSON;

class dent.tools.UltraLoader {
	private static var slots:Number=null;	  // max slots to use
	private static var active:Number=null;	  // active loaders
	private static var slowqueue:Array=null;  // low priority queue
	private static var fastqueue:Array=null;  // high priority queue

	// json
	public static var usefast:Boolean=false;
	public static var fast:FastJSON=null;

//********* init/settings
	public static function init(s) {
		trace("setting up ultraloader");

		if (s==undefined) s=5;

		cleanup()

		slowqueue=new Array();
		fastqueue=new Array();
		slots=s;
		active=0;

		// DEV NOTE: slots really important
		//           Flashlite has a hard 5 external call limit.
		//           FLDH the limit is relaxed but testing showed it queued the rest on it's own
		//           data priority defaults it to be more important than an image
		//           really easy to slow down execution because of loading too many things
		//           don't forget to reduce slots during video so we can xml straight in

		// detect fastjson in flash client
		fast = new FastJSON();
		if (fast.turboParse != undefined) {
			usefast=true;
			trace('.. fastjson will be used');
		} else {
			trace('.. designvox json will be used');
		}

		trace("UltraLoader inited");
	}

	public static function change_slots(s) {
		if(s < 1) s=1;
		slots=s;
		trace("ultraloader slots changed to "+slots);
	}

//********  loads

	// image
	public static function image(parentMC, url, options, priority, callback, passthrough) {
		var o:Object=def_queue("i");
		o.parentMC=parentMC;
		o.url=url;
		o.callback=callback;
		o.passthrough=passthrough;

		merge_options(o, options);

		if(safe()) {
			start_image(o);
		} else {
			add_queue(priority, o);
		}
	}

	// json
	public static function json(url, options, priority, callback, passthrough, finalpassthrough) {
		var o:Object=def_queue('j');
		o.url=url;
		o.callback=callback;
		o.passthrough=passthrough;
		o.finalpassthrough=finalpassthrough;

		merge_options(o, options);

		if(safe()) {
			start_data(o);
		} else {
			if(priority!=1) priority=2; // data defaults to 2, null valid call
			add_queue(priority, o);
		}
	}

// ************** QUEUE

	private static function add_queue(priority, o) {
		if(priority==undefined) priority=1;

		switch(priority) {
			case 2:
				fastqueue.push(o);
				break;
			default:
				slowqueue.push(o);
				break;
		}
		trace("queued "+priority);
	}

	private static function def_queue(t) {
		var o:Object=new Object();

		o.callback=null;	  		// callback when done
		o.passthrough=null;	  		// passthrough callback
		o.finalpassthrough=null;	// passthrough callback
		o.added=new Date();   		// timestamp when added
		o.t=t; 				  		// type of load
		o.retries=0;		  		// # of retries left
		o.data=null;		  		// result data

		switch(t) {
			case 'i':				// images
				o.parentMC=null;
				o.name=null;
				o.width=50;			// large enough to see it loaded but you screwed up
				o.height=50;
				o.x=0;
				o.y=0;
				o.scale=null;
				o.align='center';
				o.url=null;
				o.fortile=null;
				o.hl="both";
				o.visible=true;
				o.alpha=100;
				break;
			case 'j':				// json
				break;
		}

		return o;
	}

	private static function merge_options(o, options) {
		if(Util.notfound(options)) return;

		for (var p:String in options) {
			if (o.hasOwnProperty(p)) {
				o[p]=options[p];
				trace("merged "+p+":"+o[p]);
			}
		}
	}

	// start the next load.
	private static function start_next() {
		trace("start_next");
		if(!safe()) {
			trace("skipped queue loading, no room to load");
			return;
		}

		if(fastqueue.length>0) {
			var o:Object=fastqueue.splice(0,1)[0];
			add_from_queue(o);
		} else if(slowqueue.length>0){
			var o:Object=slowqueue.splice(0,1)[0];
			add_from_queue(o);
		} else {
			trace("nothing to load: F-"+fastqueue.length+" S-"+slowqueue.length);
			active--;
			return;
		}
	}

	private static function add_from_queue(o) {
		switch(o.t) {
			case 'i':
				start_image(o);
				break;
			case 'j':
				start_data(o);
				break;
			default:
				active--;
		}
	}

	private static function safe() {
		trace("active loaders: "+active);
		if(active<slots) {
			active++;
			return true;
		} else {
			return false;
		}
	}



// ************ images

	private static function start_image(l) {
		// still needed
		if(Util.notfound(l.parentMC)) {
			trace("image canceled, parent missing ");
			load_done(false, l);
			return;
		}

		// fix url
		l.url=Util.fix_url(l.url);

		// valid url (5=1.ext long minimum filename)
		if(Util.unknown(l.url) || l.url.length < 5) {
			trace("image canceled, bad url "+l.url);
			load_done(false, l);
			return;
		}

		// name
		trace(l.name);
		if(Util.unknown(l.name)) {
			trace("image canceled, no mc name to use");
			load_done(false, l);
			return;
		}

		// make, size, position master clip if needed
		if(Util.notfound(l.parentmc[l.name])) {
			trace("creating master clip");

			if(Util.unknown(l.depth)) l.depth=l.parentMC.getNextHighestDepth();
			var master:MovieClip=l.parentMC.createEmptyMovieClip(l.name, l.depth);
		}

		// highlight adjust
		if(l.fortile!=null) {
			trace("highlight for tile setup");

			if(l.hl=='yes') {
				l.parentMC[l.name]._visible=false;
			} else {
				l.parentMC[l.name]._visible=true;
			}
			trace("... hl: "+l.hl);
		} else {
			l.parentMC[l.name]._visible=l.visible;
		}
		trace("... starting _vis:"+l.parentMC[l.name]._visible);

		l.parentMC[l.name]._alpha=l.alpha;
		trace("... starting _alpha:"+l.parentMC[l.name]._alpha);

		// make the load clip we're using
		l.clip=l.parentMC[l.name].createEmptyMovieClip("il_"+l.added.getTime(), l.parentMC.getNextHighestDepth());

		// setup the load
		var loader:MovieClipLoader=new MovieClipLoader();
		l.loader=loader;

		loader.addListener(l);

		l.onLoadInit = function(targetMC:MovieClip) {
			var w:Number=targetMC._width;
			var h:Number=targetMC._height;
			var aspect=targetMC._width/targetMC._height;

			// scale
			switch(this.scale) {
				case 'aspect':
					if(aspect != this.width/this.height) {
						if (w>this.width) {
							w = this.width;
							h = Math.round(w/aspect);
						} else if (h>this.height) {
							h = this.height;
							w = Math.round(h*aspect);
						}
					}
					break;
				case 'width':
					if(w!=this.width) {
						w = this.width;
						h = Math.round(w/aspect);
					}
					break;
				case 'height':
						if (h!=this.height) {
							h = this.height;
							w = Math.round(h*aspect);
						}
					break;
				default:
					w=this.width;
					h=this.height;
					break;
			}

			// align
			switch(this.align) {
				case 'left':
					targetMC._y=(this.height/2) - (h/2);  // center v
					targetMC._x=0;
					break;
				case 'right':
					targetMC._y=(this.height/2) - (h/2);  // center v
					targetMC._x=this.width-w;
					break;
				case 'top':
					targetMC._x=(this.width/2) - (w/2);   // center h
					targetMC._y=0;
					break;
				case 'bottom':
					targetMC._x=(this.width/2) - (w/2);   // center h
					targetMC._y=this.height-h;
					break;
				case 'center':
					targetMC._x=(this.width/2) - (w/2);   // center h
					targetMC._y=(this.height/2) - (h/2);  // center v
					break;
				default:     // no alignment
					break;
			}

			// final position
			targetMC._parent._x=this.x;
			targetMC._parent._y=this.y;

			// final size
			targetMC._width = w;
			targetMC._height = h;
		};

		l.onLoadComplete = function(targetMC:MovieClip, httpStatus:Number):Void {
			//find/remove the neighbor
			for (var i in targetMC._parent) {
				if(typeof(targetMC._parent[i]) == "movieclip" && targetMC._parent[i]._name!=targetMC._name) {
					targetMC._parent[i].removeMovieClip();
				}
			}

			load_done(true, this);
		}

		l.onLoadError = function(targetMC:MovieClip, errorCode:String, httpStatus:Number) {
			if (this.retries > 0) {
				this.retries--;
				this.loader.loadClip(this.url, this.clip);
			} else {
				// cleanup
				targetMC.removeMovieClip();
				load_done(false, this);
			}
		}

		// start the load
		l.added=new Date();
		l.loader.loadClip(l.url, l.clip);
	}

// ************ data

	private static function start_data(d) {
		// validate url
		if(Util.unknown(d.url) || d.url.length < 8) {  // http:// or file:// = 7, url needs to be at least 8 to have somethign to try to load
			trace("data load skipped, bad url");
			load_done(false, d);
			return;
		}

		if(Util.notfound(d.callback)) {
			trace("data load skipped, no callback");
			load_done(false, d);
			return;
		}

		d.loader=new LoadVars();
		d.loader.onData = function(src:String) {
			if (Util.notfound(src)) {
				load_done(false, d);
			} else {
				d.data=parseJSON(src);
				load_done(true, d);
			}
		};

		d.added=new Date();
		d.loader.load(d.url);
	}

	private static function parseJSON(data) {
		if(usefast){
			return fast.turboParse(data);
		} else {
			return JSON.parse(data);
		}
	}

// ************ completion
	public static function load_done(success, l) {
		if(success) {
			trace("done");
			l.callback(true, l.data, l.passthrough, l.finalpassthrough);
		} else {
			trace("errored");
			l.callback(false, l.data, l.passthrough,l.finalpassthrough);
		}

		delete l;
		l=null;

		active--;
		start_next();
	}

// ************ class cleanup

	// cleanup/destroy
	public static function cleanup() {
		delete slowqueue;
		delete fastqueue;
		slowqueue=null;
        fastqueue=null;
		active=null;
	}
}