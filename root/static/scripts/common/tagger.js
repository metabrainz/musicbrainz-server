import $ from 'jquery';

$(function () {
    $('a.tagger-icon').click(function (event) {
        event.preventDefault();
        if (window.opera) {
            var iframe = document.createElement('iframe');
            iframe.src = this.href;
            iframe.style.display = 'none';
            $('body').append(iframe);
        }
        else {
            var tagger = new Image();
            tagger.src = this.href;
        }
    });
});
