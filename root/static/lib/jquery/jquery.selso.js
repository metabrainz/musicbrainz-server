/*
 * SelSo 1.1 - Client-side selection sorter
 * Version 1.1
 *
 * Copyright (c) 2007 Guillaume Andrieu
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

/**
 *
 * @description Takes a selection, for example some li elements in a ul,
 * and sorts them according to the value of some classed element
 * they all share. The elements of the selection must have an id attribute.
 *
 * This version contains a bug-fix, now selso does not remove the events
 * attached to the sorted elements. See http://plugins.jquery.com/node/2019.
 *
 * It also contains a modification given by Gerardo Contijoch, which is the reason
 * for the 1.0.2 version : now a sorted element does not require to contain an id
 * attribute, while it previously needed one.
 *
 * @example $('li').selso({type:'num' , orderBy:'span.value'});
 * @desc Will sort all the li's elements in their respective ul, according to
 * the numerical value in the span.value contained in the li.
 *
 * @example $('li').selso({type:'num' , orderBy:'span.value',direction:'desc'});
 * @desc Will sort all the li's elements in their respective ul, according to
 * the numerical value in the span.value contained in the li, in descending order.
 *
 * @example $('li').selso({type:'alpha' , extract:function(obj){ return $(obj).attr('id'); }});
 * @desc Will sort all the li's elements in their respective ul, according to
 * the result of the extract function, here giving the id attribute of each li.
 *
 *
 * @param Object settings An object literal containing key/value pairs to provide optional settings.
 *
 * @option String type (optional)       A String giving the type of ordering : for the moment, only 'alpha' or 'num'
 *                        Default value: "alpha"
 *
 * @option String orderBy (optional)      A String representing a jQuery selector. This selector will be applied inside each selected element.
 *                        Default value: "span.value"
 *
 * @option String direction (optional)      A string to know in which order to sort : 'asc'ending or descending.
 *                        'asc' means ascending, anything else means descending
 *                        Default value: "asc"
 *
 * @option Function extract (optional)  A Function taking an element, and sending back the value given to that object in the ordering process.
 *                        Default value: none
 *
 * @option Function orderFn (optional)  A function that will be given as the parameter of the .sort() function.
 *                        Its parameters are two objects of type {id:'...',val:'...'}, and returns a number,
 *                        positive if the first object is greater,
 *                        negative is the second is greater,
 *                        0 otherwise.
 *                        Default value: none
 * @type jQuery
 *
 * @name selso
 *
 * @cat Plugins/Selso
 *
 * @author Guillaume Andrieu/subtenante@yahoo.fr
 *
 * @history
 *   1.1 : compatible with latest jquery version : 1.4
 */

(function($) {

  $.extend({
    selso:{

      defaults:{
        type:'alpha',               // type of sorting : alpha, num, date, ip, ...
        orderBy:'span.value',       // selector of the elements containing the value to order by
        direction:'asc'
      },

      extractVal: function(type,text){
        if (type=='num'){
          return 1*text;
        }
        return text;
      },

      accentsTidy: function(s){
        var r=s.toLowerCase();
        r = r.replace(/\s/g,"");
        r = r.replace(/[àáâãäå]/g,"a");
        r = r.replace(/æ/g,"ae");
        r = r.replace(/ç/g,"c");
        r = r.replace(/[èéêë]/g,"e");
        r = r.replace(/[ìíîï]/g,"i");
        r = r.replace(/ñ/g,"n");
        r = r.replace(/[òóôõö]/g,"o");
        r = r.replace(/œ/g,"oe");
        r = r.replace(/[ùúûü]/g,"u");
        r = r.replace(/[ýÿ]/g,"y");
        r = r.replace(/\W/g,"");
        return r;
      },

      orderAlpha: function(a,b){
        if (a==b){
          //console.log(a+' = '+b);
          return 0;
        }
        var array = [a,b];
        array.sort();
        if (array[0]==a){
          //console.log(a+' < '+b);
          return -1;
        }
        //console.log(a+' > '+b);
        return 1;

      },

      alphaGreaterThan: function(s1,s2){
        return this.orderAlpha(s1,s2);
      },

      stablesort: function(pArray,orderFn){
        var lArray = pArray;
        var tmp;
        for (var i=1;i<lArray.length;i++){

          var j=1;
          var comp;
          while(i>=j && (comp = (orderFn(lArray[i-j],lArray[i])>0))) {
            j++;
          }
          //console.log(j);
          if (j>0){
            tmp = lArray.slice(0,i-j+1);
            tmp.push(lArray[i]);
            tmp = tmp.concat(lArray.slice(i-j+1,i));
            if (i<lArray.length-1) {
              tmp = tmp.concat(lArray.slice(i+1));
            }
            lArray = tmp;
          }
        }
        return lArray;
      }
    }
  });

  $.fn.extend({

    outhtml: function() {
      if (this.length)
        return $('<div/>').append($(this[0]).clone(true)).html();
      return null;
    },

    // thanks to alpar
    prependToParent : function(){
      return this.each(function(){
        obj=$(this);
        var parent = obj.parent();
        obj.detach();
        parent.prepend(obj);
      });
    },

    selso: function(settings) {

      var type = settings.type || $.selso.defaults.type;
      var orderBy = settings.orderBy || $.selso.defaults.orderBy;
      var direction = settings.direction || $.selso.defaults.direction;
      var extractFn = settings.extract; // function that reads and parses the value in the selected element, if setted, orderBy will be ignored
      var orderFunction = settings.orderFn;

      if (!$.isFunction(extractFn)){
        extractFn = function(obj){
          return $.selso.extractVal(type,$(orderBy,obj).text());
        };
      }

      var arr = [];
      this.each(function(){
          arr.unshift({
          obj:this, // now we keep a reference of the object and not its id
          val:extractFn(this)
        });
      });

      // Setting the ordering function if not given in the settings
      if ($.isFunction(orderFunction)){
      }
      else if (type=='num'){
        orderFunction = function(a,b){return a.val-b.val;};
      }
      else { // alpha by default...
        if (type=='accents') {
          $.map(arr,function(n){n.val = $.selso.accentsTidy(n.val);});}
        orderFunction = function(a,b){return $.selso.alphaGreaterThan(a.val,b.val);};
      }
      var finalOrderFn=orderFunction;
      if(direction=='asc'){
        finalOrderFn = function(a,b){
          return -1*orderFunction(a,b);
        };
      }
      arr = $.selso.stablesort(arr,finalOrderFn);

      for (var i = 0; i < arr.length; i++) {
          $(arr[i].obj).prependToParent();
      }

      return this;

    }
  });

})(jQuery);