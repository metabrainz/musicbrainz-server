/* aqCookie v1.0 - Simpler way to get and sets cookies.
   Copyright (C) 2008 Paul Pham <http://aquaron.com/~jquery/aqCookie>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
(function($){
$.aqCookie = {
   domain: '',
   secToExpire: 3153600000,

   get: function(carr) {
      if (typeof carr == 'string')
         carr = [carr];

      var hash = [];
      var ca = document.cookie.split(';');
      for(var i=0;i < ca.length;i++) {
         var c = ca[i];
         while (c.charAt(0)==' ') c = c.substring(1,c.length);

         for(var j=0;j<carr.length;j++) {
            var n = carr[j]+'=';
            if (c.indexOf(n) == 0) 
               hash[carr[j]] = c.substring(n.length,c.length);
         }
      }
      return hash;
   },

   set: function(k,v) {
      if (v) {
         var exp = new Date();
         exp.setTime(exp.getTime() + $.aqCookie.secToExpire);
         document.cookie = k + "=" + v + "; path=/; domain="+$.aqCookie.domain+"; expires="+ exp.toGMTString() + '";';
      } else
         document.cookie = k + "=; path=/; domain="+$.aqCookie.domain+"; expires=Thu, 01-Jan-1970 00:00:01 GMT;";
   },

   all: function(filter) {
      var hash = [];
      var ca = document.cookie.split(';');
      var re = new RegExp(filter);
      for(var i=0;i < ca.length;i++) {
         var c = ca[i];
         while (c.charAt(0)==' ') c = c.substring(1,c.length);
         if (!c.match(re))
            continue;
         hash.push(c.substring(0,c.indexOf('=')));
      }
      return hash;
   },

   del: function(k) { $.aqCookie.set(k) }
};
})(jQuery);
