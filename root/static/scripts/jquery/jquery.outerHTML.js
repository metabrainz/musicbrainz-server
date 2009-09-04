/** 
 * Based on outerHTML functions from http://brandonaaron.net/blog/2007/06/17/jquery-snippets-outerhtml
 * Originally by Brandon Aaron, with multi-document support added by Brian Grinstead, 
 * and a <script> workaround for http://dev.jquery.com/ticket/4801 from Al.
 */

// Note that element tags will be returned however the browser gives them; this means divs will be XHTML-standards
// compliant on Firefox ("<div>"), but non-compliant on Opera or IE ("<DIV>").

$.fn.outerHTML = function (s) {
    if (this.find("script").length === 0) {
        var doc = this[0] ? this[0].ownerDocument : document;
        return $('<div>', doc).append(this.eq(0).clone()).html();
    } else {
        var p = document.createElement('p');
        var c = this.eq(0).clone();
        p.appendChild(c[0]);
        return (s) ? this.before(s).remove() : p.innerHTML;
    }
};
