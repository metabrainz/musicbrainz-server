$(function() {
    $(".prev").each(function(i) {
        $(".change:eq("+i+")").prev().html("<strong>Old:<br />New:<br />Diff:</strong>");
        var dmp = new diff_match_patch();
        var diffBefore = $(".prev:eq("+i+")").text();
        var diffAfter = $(".new:eq("+i+")").text();
        var diff = dmp.diff_main(diffBefore, diffAfter);
        dmp.diff_cleanupSemantic(diff);
        var diffHTML = dmp.diff_prettyHtml(diff);
        $(".prev:eq("+i+")").parent().append("<br /><span>" + diffHTML + "</span>");
    });
    $(".change").removeClass("change");
    $(".prev").removeClass("prev");
    $(".new").removeClass("new");
});
