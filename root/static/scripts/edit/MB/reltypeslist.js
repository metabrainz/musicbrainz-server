import $ from 'jquery';

$(function () {
  $('.reldetails').hide();

  $('.toggle').click(function () {
    $(this)
      .parent()
      .next('.reldetails')
      .toggle();
    const isHidden = $(this)
      .parent()
      .next('.reldetails')
      .is(':hidden');
    if (isHidden) {
      $(this).text('more');
    } else {
      $(this).text('less');
    }
  });

  $('#showAll').click(function () {
    $('.reldetails, #hideAll').show();
    $('#showAll').hide();
    $('.toggle').text('less');
  });

  $('#hideAll').click(function () {
    $('.reldetails, #hideAll').hide();
    $('#showAll').show();
    $('.toggle').text('more');
  });
});
