  $('#myModal').modal('hide')

    jQuery(function ($) {
        function check_values() {
            if ($("#username").val().length != 0 && $("#password").val().length != 0) {
                $("#button1").removeClass("hidden").animate({ left: '250px' });
                $("#lock1").addClass("hidden").animate({ left: '250px' });
            }
        }
    });

   // var ctx = document.getElementById("canvas_line").getContext("2d");
   
   var data = {
    labels: ["January", "February", "March", "April", "May", "June", "July"],
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: [65, 59, 80, 81, 56, 55, 40]
        },
        {
            label: "My Second dataset",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: [28, 48, 40, 19, 86, 27, 90]
        }
    ]
};
    var option = {
        responsive: !0
    };

    // var myLine = new Chart(ctx).Line(data,option);

 
   window.requestAnimationFrame = (function(){
    return  window.requestAnimationFrame       ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame    ||
            function( callback ){
              window.setTimeout(callback, 1000 / 60);
            };
  })();

  var speed = 1000;
  (function currencySlide(){
      var currencyPairWidth = $('.slideItem:first-child').outerWidth();
      $(".modal-backdrop").remove();
      $("#news1,#news2").newsticker();
      $(".slideContainer").animate({marginLeft:-currencyPairWidth},speed, 'linear', function(){
                  $(this).css({marginLeft:0}).find("li:last").after($(this).find("li:first"));
          });
          requestAnimationFrame(currencySlide);
  })();
  
  $('.carousel').carousel({
        interval: 3000
    })




  