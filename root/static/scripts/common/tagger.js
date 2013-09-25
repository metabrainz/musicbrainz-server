$(function() {
    $('a.tagger-icon').click(function(event) {
        event.preventDefault();
        tagger = new Image();
        tagger.src = this.href;
    });
});
