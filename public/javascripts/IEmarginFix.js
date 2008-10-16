/***************************************************************************
* Internet Explorer Margin Fix
* Copyright 2002-2005 by David Schontzler and contributors
* http://iemarginfix.sourceforge.net
* Distributed under the Academic Free License 2.1 or above
* Description:  This script will fix the horizontal margin support in IE5-7
***************************************************************************
* Version: 2.4.0.src
* $Revision: 14 $
* $LastChangedDate: 2007-05-21 08:33:19 -0700 (Mon, 21 May 2007) $
***************************************************************************/

IEmarginFix = {
	list : [],
	
	ss : null,

	needsFixed: (function() {
		var ua = navigator.userAgent;
		return /msie [5-7]\./i.test(ua) && !/mac/i.test(ua)
			&& document.compatMode != "CSS1Compat" && window.attachEvent
			&& document.styleSheets.length > 0;
	})(),
	
	init : function() {
		if(IEmarginFix.needsFixed) {
			this.ss = document.styleSheets;
			var auto, lop, list, s, i, a;
			auto = [];
			lop = [];
			list = [];
			s = this.getRules();
			for(i=0; i<s.length; i++) {
				if( this.checkMargin(s[i][1]) ) {
					auto[auto.length] = s[i][0];
				} else if( this.checkLopsided(s[i][1]) ) {
					lop[lop.length] = s[i][0];
				}
			}
			for(i=0; a = auto[i]; i++) {
				this.ss[this.ss.length-1].addRule(a, "margin-left : expression( IEmarginFix.autoFix(this) );");
			}
			for(i=0; a = lop[i]; i++) {
				this.ss[this.ss.length-1].addRule(a, "margin-left : expression( IEmarginFix.lopsidedFix(this) );");
			}
			this.list = auto.length > 0 ? lop.length > 0 ? auto.concat(lop) : auto : lop;
			window.attachEvent("onload", IEmarginFix.checkInline);
		}
	},
	
	autoFix : function(elm) {
		var rslt = "auto", w = elm.currentStyle.width;
		var id = elm.id ? "#" + elm.id : elm.className ? elm.tagName + "." + elm.className : elm.tagName; // Credit: BS
		if(w.indexOf("%") != -1) {
			rslt = ( 100 - parseInt(w) )/2 + "%";
			IEmarginFix.ss[IEmarginFix.ss.length-1].addRule(id, "margin-left : " + rslt + "; margin-right : " + rslt + "; width : 100%");
		} else
			IEmarginFix.ss[IEmarginFix.ss.length-1].addRule(id, "margin-left : expression( IEmarginFix.pxAutoFix(this) );");
		return rslt;
	},
	
	// so we don't have to go through the if...else all over again!
	pxAutoFix : function(elm) {
		var rslt, par = elm.parentNode;
		rslt = par.clientWidth > 0 ? par.clientWidth : par.scrollWidth;
		rslt = (rslt - elm.offsetWidth) / 2;
		return Math.max(rslt, 0);
	},
	
	lopsidedFix : function(elm) {
		var par = elm.parentNode, parWidth, rslt;
		parWidth = par.clientWidth > 0 ? par.clientWidth : par.scrollWidth;
		rslt = parWidth - elm.offsetWidth;
		if( elm.currentStyle.marginRight.indexOf("px") != -1 ) {
			rslt -= parseInt( elm.currentStyle.marginRight );
		} else if( elm.currentStyle.marginRight.indexOf("%") != -1 ) {
			rslt -= parseInt(elm.currentStyle.marginRight) * 0.01 * parWidth;
		}
		rslt -= ( parseInt(par.currentStyle.paddingLeft) + parseInt(par.currentStyle.paddingRight) );
		return rslt;
	},
	
	checkInline : function() {
		var i, a, elm, blk, list = [], auto = IEmarginFix.list;
		for(i=0; a = auto[i]; i++) {
			if( a.indexOf(".") != -1 ) { // classes
				list = list.concat( IEmarginFix.getClass( a.substring(a.indexOf(".")+1) ) );
			} else if( a.charAt(0) == '#' ) { // ids
				list[list.length] = document.all[a.substring(1)];
			} else { // tags
				elm = document.getElementsByTagName(a);
				if(elm.length > 0) {
					for(i=0; i < elm.length; i++) {
						list = list.concat( elm.item(i) );
					}
				}
			}
		}
		for(i=0; i<list.length; i++) {
			elm = list[i];
			if(elm && elm.style) {
				blk = IEmarginFix.getStyle(elm, "display");
				if(blk != "block" && ( IEmarginFix.ie50 ? !IEmarginFix.ie50check(elm.tagName) : blk != "list-item" ) ) {
					elm.style.margin = 0;
				}
			}
		}
	},
	
	checkMargin : function(str) {
		return ( str.search(/position\s*:\s*absolute/i) == -1 && (
			str.match(/margin\s*:\s*auto(;|$)/i) || str.match(/margin\s*:\s*\S+\s+auto(;|$)/i)
			|| ( str.match(/margin-left\s*:\s*auto/i) && str.match(/margin-right\s*:\s*auto/i) )
			|| str.match(/margin\s*:\s*\S+\s+auto\s+\S+(;|$)/i) || str.match(/margin\s*:\s*\S+\s+auto\s+\S+\s+auto/i)
			)
		);
	},
	
	checkLopsided : function(str) {
		return ( str.search(/position\s*:\s*absolute/i) == -1 && (
				str.match(/margin-left\s*:\s*auto/i) && str.match(/margin-right\s*:\s*\d+(px|%)?/i)
				|| str.match(/margin-left\s*:\s*auto/i) && !str.match(/margin-right/i)
			)
		);
	},
	
	// these next few methods are basically for IE 5.0's bad interpretation of the "display" property (always returning "inline" unless explicitly set, even for block elements!)
	ie50 : navigator.appVersion.toLowerCase().indexOf("msie 5.0") != -1,
	
	ie50check : function(tag) {
		var i, r = false;
		tag = tag.toUpperCase();
		for(i=0; i<this.blockElms.length; i++) {
			if(tag == this.blockElms[i]) {
				r = true;
			}
		}
		return r;
	},
	
	blockElms : ["ADDRESS", "BLOCKQUOTE", "BODY", "CENTER", "COL", "COLGROUP",
		"DD", "DIR", "DIV", "DL", "DT", "FIELDSET", "FORM", "FRAME", "HN", "HR",
		"IFRAME", "LEGEND", "LI", "LISTING", "MARQUEE", "MENU", "OL", "P",
		"PLAINTEXT", "PRE", "TABLE", "TBODY", "TD", "TFOOT", "TH", "THEAD",
		"TR", "UL", "XMP"],
	// end IE5.0 detect
	
	getClass : function(cls) {
		var el, r, i;
		el = document.all ? document.all : document.getElementsByTagName('*');
		r = [];
		for(i=0; el[i]; i++) {
			if(el[i].className == cls) { r[r.length] = el[i]; }
		}
		if(r.length==0) { r = null; }
		return r;
	},
	
	getRules : function(wh) {
		var s = null;
		if(document.styleSheets && document.styleSheets.length) {
			var i, j, k, m, x, y, is = true, screen = true;
			s = [];
			for(i=0; i < document.styleSheets.length; i++) {
				j = document.styleSheets.item(i);
				if(wh) { is = (j.title || j.id) == wh; }
				if( typeof j.media == "string" && j.media.length > 0 && !j.media.match(/^(screen)|(media)$/i) ) {
					screen = false;
				} else {
					screen = true;
				}
				if(!j.disabled && screen && is) {
					if(j.rules) {
						if(j.imports && j.imports.length) {
							for(k=0; k < j.imports.length; k++) {
								for(x=0; y = j.imports[k].rules[x]; x++) {
									s[s.length] = [y.selectorText, y.style.cssText];
								}
							}
						}
						for(k=0; m = j.rules[k]; k++) {
								s[s.length] = [m.selectorText, m.style.cssText];
						}
					} else {
						return null;
					}
				}
				if(wh && is) { break; } else { is = true; }
			}
		}
		return s;
	},
	
	getStyle : function(obj,sty) {
		var sty2 = IEmarginFix.compactStyle(sty);
		var r = obj.style[sty2];
		if(r=='') {
			if(document.defaultView) {
				r = document.defaultView.getComputedStyle(obj,'').getPropertyValue(sty);
			}
			else r = obj.currentStyle[sty2];
		}
		if(!r) { r = null; }
		return r;
	},

	compactStyle : function(str) {
		var s = str.split('-');	var o = [s[0]];
		for(i=1;(j=s[i]);i++) { o[o.length] = j.charAt(0).toUpperCase(); o[o.length] = j.substring(1) };
		return o.join('');
	}
};
IEmarginFix.init();
