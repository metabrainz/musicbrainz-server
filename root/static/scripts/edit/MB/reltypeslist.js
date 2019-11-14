import $ from 'jquery';

$(function () {
    $(".reldetails").hide();

    $(".toggle").click(function () {
        $(this).parent().next(".reldetails").toggle();

        if ($(this).parent().next(".reldetails").is(':hidden')) {
            $(this).text("more");
        } else {
            $(this).text("less");
        }
    });

    $("#showAll").click(function () {
        $(".reldetails, #hideAll").show();
        $("#showAll").hide();
        $(".toggle").text("less");
    });

    $("#hideAll").click(function () {
        $(".reldetails, #hideAll").hide();
        $("#showAll").show();
        $(".toggle").text("more");
    });
});
