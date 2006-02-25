/* arrayprototype.js
 * by Peter Belesis. v1.0 000516
 * Copyright (c) 2000 Peter Belesis. All Rights Reserved.
 * Originally published and documented at http://www.dhtmlab.com/
 * License to use is granted if and only if this entire copyright notice
 * is included.
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

if (Array.prototype.push && ([0].push(true)==true)) Array.prototype.push = null;
if (Array.prototype.splice && typeof([0].splice(0)) == "number") Array.prototype.splice = null;
if(!Array.prototype.shift) {
	Array.prototype.shift = function() {
		firstElement = this[0];
		this.reverse();
		this.length = Math.max(this.length-1,0);
		this.reverse();
		return firstElement;
	};
}
if(!Array.prototype.unshift) {
	Array.prototype.unshift = function() {
		this.reverse();
		for(var i=arguments.length-1;i>=0;i--) {
			this[this.length] = arguments[i];
		}
		this.reverse();
		return this.length;
	};
}
if(!Array.prototype.push) {
	Array.prototype.push = function() {
		for (var i=0;i<arguments.length;i++) {
			this[this.length] = arguments[i];
		};
		return this.length;
	};
}
if(!Array.prototype.pop) {
	Array.prototype.pop = function() {
	    lastElement = this[this.length-1];
		this.length = Math.max(this.length-1,0);
	    return lastElement;
	};
}
if(!Array.prototype.splice) {
	Array.prototype.splice = function(ind,cnt){
        if (arguments.length == 0) return ind;
        if (typeof ind != "number") ind = 0;
        if (ind < 0) ind = Math.max(0,this.length + ind);
        if (ind > this.length) {
            if (arguments.length > 2) {
           		ind = this.length;
            } else {
            	return [];
            }
        }
        if (arguments.length < 2) {
       		cnt = this.length-ind;
       	}
        cnt = (typeof cnt == "number") ? Math.max(0,cnt) : 0;
        removeArray = this.slice(ind, ind+cnt);
        endArray = this.slice(ind+cnt);
        this.length = ind;
        var i;
        for (i=2;i<arguments.length;i++) {
            this[this.length] = arguments[i];
        }
        for (i=0;i<endArray.length;i++) {
            this[this.length] = endArray[i];
        }
        return removeArray;
    };
}