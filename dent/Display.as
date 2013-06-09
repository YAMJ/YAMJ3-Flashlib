import dent.Common;
import dent.tools.UltraLoader;
import dent.tools.Util;
import dent.tools.StringUtil;
import dent.Background;

class dent.Display {
	private var mainMC:MovieClip=null;      // screen mc

	private var layout:Object=null;    		// quick lookup data (for lite)
	private var gridhighlight:Object=null;  // tile highlight cheat sheet


	public function Display(mainMC) {
		this.cleanup();

		this.mainMC=mainMC;
		this.layout=new Object();
		this.gridhighlight=new Object();

		trace("display ready");
	}

	public function draw(clip, data, fortile) {
		trace("draw");

		if(Util.unknown(data)) {
			return false;
		}

		var cnt:Number=0;
		for(var i=0; i < data.length; i++) {
			if(Util.unknown(data[i]['name'])) {
				data[i]['name']="NONAME_"+cnt;
				if(!Util.notfound(fortile)) this.update_quick(data[i],fortile);
			} else {
				this.update_quick(data[i],fortile);
			}

			data[i]['depth']=cnt;
			trace(". "+data[i]['name']+" depth: "+data[i]['depth']+" type:"+data[i]['type']);

			switch(data[i]['type']) {
				case 'text':
					draw_text(data[i],clip,fortile);
					break;
				case 'image':
					draw_image(data[i],clip,fortile);
					break;
				default:
					trace(".. skipped type: "+data[i]['type']);
					break;
			}
			cnt++;
		}

		if(this.gridhighlight[fortile].need) {
			this.gridhighlight[fortile].need=false;

			// if nothing to alter, we can speed up later knowing it now
			if(this.gridhighlight[fortile].hl.length==0 && this.gridhighlight[fortile].nohl.length==0) {
				this.gridhighlight[fortile].skip=true;
			}
		}

		return (cnt>0);
	}

	private function update_quick(data,fortile) {
		if(Util.notfound(fortile)) {
			switch(data['type']) {
				case 'text':
				case 'image':
					this.layout[data.name]=data;
					break;
				case 'grid':
					this.gridhighlight[data.name]=new Object({skip:false, need:true});
					this.gridhighlight[data.name].hl=new Array();
					this.gridhighlight[data.name].nohl=new Array();
			}
		} else {
			if(!this.gridhighlight[fortile].need) return;

			switch(data.hl) {
				case 'yes':
					this.gridhighlight[fortile].hl.push(data.name);
					break;
				case 'no':
					this.gridhighlight[fortile].nohl.push(data.name);
					break;
			    // both has no altering, skipped
			}
		}
	}

	public function tile_highlight(grid, rowname, tilename, highlight) {
		if(this.gridhighlight[grid].skip) return;

		if(highlight) {
			var hl:Boolean=true;
			var nohl:Boolean=false;
		} else {
			var hl:Boolean=false;
			var nohl:Boolean=true;
		}

		// toggle higlights
		if(this.gridhighlight[grid].hl.length != 0) {
			for(var i in this.gridhighlight[grid].hl) {
				this.mainMC[grid]['GRID'][rowname][tilename][this.gridhighlight[grid].hl[i]]._visible=hl;
			}
		}

		// toggle no highlights
		if(this.gridhighlight[grid].nohl.length != 0) {
			for(var i in this.gridhighlight[grid].nohl) {
				this.mainMC[grid]['GRID'][rowname][tilename][this.gridhighlight[grid].nohl[i]]._visible=nohl;
			}
		}
	}

	public function screen_update(data) {
		if(Util.empty(data)) {
			trace("screen_update: no data");
			return;
		}

		trace("screen_updating");

		for(var i=0; i < data.length; i++) {
			trace(". "+data[i]['name']+" type:"+data[i]['type']);

			switch(data[i]['type']) {
				case 'skip':
					trace(".. skipped");
					break;
				default:
					trace(".. lite merge");
					this.lite_update(data[i]);
					break;
			}
		}
	}

	private function lite_update(data) {
		if(Util.notfound(data['name'])) {
			trace("... skipped, no name");
			return;
		}

		if(Util.notfound(this.layout[data['name']])) {
			trace("... skipped, missing from layout");
			return;
		}

		var n:Object=this.layout[data['name']].clone(); // copy orig
		n.mergeObjects(data, true);					    // merge difference

		switch(n.type) {
			case 'text':
				draw_text(n,this.mainMC);
				break;
			case 'image':
				draw_image(n,this.mainMC);
				break;
		}
	}

	private function draw_text(block,thisMC:MovieClip,fortile) {
		trace("... "+block.name);

		// draw
		if(Util.notfound(thisMC[block.name])) {
			trace("... adding textclip");
			thisMC.createTextField(block.name, block.depth, Number(block.x), Number(block.y), Number(block.width), Number(block.height));
		}

		// adjust
		if(Util.truefalse(block.multiline, false)) {
			thisMC[block.name].multiline=true;
			thisMC[block.name].wordWrap=true;
		}

		var txtfmt = new TextFormat();
		if(block.font != undefined) {
			txtfmt.font=block.font;
		}
		txtfmt.align=block.align;
		txtfmt.size=Number(block.size);
		txtfmt.color=parseInt(block.color, 16);
		txtfmt.bold=Util.truefalse(block.bold, false);
		txtfmt.italic=Util.truefalse(block.italic, false);
		txtfmt.underline=Util.truefalse(block.underline, false);

		// fill
		if(StringUtil.beginsWith(block.name, "clock")) {
			thisMC[block.name].text=Background.lastclock;
		} else if(StringUtil.beginsWith(block.name, "date")) {
			thisMC[block.name].text=Background.lastdate;
		} else if(StringUtil.beginsWith(block.name, "dowshort")) { // short must be before dow
			thisMC[block.name].text=Background.lastshortdow;
		} else if(StringUtil.beginsWith(block.name, "dow")) {
			thisMC[block.name].text=Background.lastdow;
		} else if(!Util.blank(block.text)) {
			thisMC[block.name].text=block.text;
		} else {
			thisMC[block.name].text=' ';   // space needed for txtfmt to take
		}

		thisMC[block.name].setTextFormat(txtfmt);
		delete txtfmt;

		if(!Util.notfound(fortile) && block.hl=='yes') {
			thisMC[block.name]._visible=false;
		} else {
			thisMC[block.name]._visible=true;
		}
		trace("... hl: "+block.hl+" _vis:"+thisMC[block.name]._visible);
	}

	private function draw_image(block,thisMC:MovieClip,fortile) {
		trace("... "+block.name);

		// verify we need to draw now
		if(Util.unknown(block.url)) {
			trace('.... reference, nothing to draw yet');
			return;
		}

		// adjust url if needed
		if(!StringUtil.beginsWith(block.url, "http://") && !StringUtil.beginsWith(block.url, "file://")) {
			block.url=block.url
		}

		if(!Util.notfound(fortile)) {
			block.fortile=fortile;
		}

		// draw
		UltraLoader.image(thisMC, block.url, block);
	}

	private function cleanup() {
		delete this.layout;
		this.layout=null;

		delete this.gridhighlight;
		this.gridhighlight=null;

		this.mainMC=null;
	}
}
