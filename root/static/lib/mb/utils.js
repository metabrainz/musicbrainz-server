/* Convert fullwidth characters to standard halfwidth Latin. */
mbz.fullWidthConverter = function (inputString) {
    if (inputString === "") {
        return "";
    }

    var convertMe = function (str, p1) {
        return String.fromCharCode (p1.charCodeAt(0) - 65248);
    };

    i = inputString.length;
    newString = [];

    do {
        newString.push (inputString[i-1].replace (/([\uFF01-\uFF5E])/g, convertMe));
    } while (--i);

    return newString.reverse ().join("");
};


