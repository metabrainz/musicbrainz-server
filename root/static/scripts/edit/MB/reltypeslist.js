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
      $(this).text(l('more'));
    } else {
      $(this).text(l('less'));
    }
  });

  $('#showAll').click(function () {
    $('.reldetails, #hideAll').show();
    $('#showAll').hide();
    $('.toggle').text(l('less'));
  });

  $('#hideAll').click(function () {
    $('.reldetails, #hideAll').hide();
    $('#showAll').show();
    $('.toggle').text(l('more'));
  });
});
