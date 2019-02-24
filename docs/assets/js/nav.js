/* Set header-click-event */
window.onload = function(e){

	$("#header_toggle_mobile").click(function () {
		$("#header_main_nav").slideToggle();
	});

	$("#content, #header_main_nav a").click(function () {
		$("#header_main_nav").slideUp();
	});

	$(document).ready(function() {
		$(".fancybox").fancybox();
	});

	$('a[href^="#"]').on('click',function (e) {
    e.preventDefault();

    var target = this.hash;
    var $target = $(target);

    $('html, body').stop().animate({
        'scrollTop': $target.offset().top
    }, 900, 'swing', function () {
        window.location.hash = target;
    });
});

}
