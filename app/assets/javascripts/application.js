// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

$(document).ready( function() {
    $("form#new_client").bind("ajax:success", function (event, xhr, settings) {
        window.location = '/';
    }).bind("ajax:error", function (event, xhr, settings, exceptions) {
        var error_messages;
        error_messages = xhr.responseJSON['error'] ? "<div class='alert-dismissible alert alert-danger text-center'> <button type=\"button\" class=\"close\" data-dismiss=\"alert\"><span aria-hidden=\"true\">&times;</span></button>" + xhr.responseJSON['error'] + "</div>" : xhr.responseJSON['errors'] ? $.map(xhr.responseJSON["errors"], function (v, k) {
            return "<div class='alert-dismissible alert alert-danger text-center'><button type=\"button\" class=\"close\" data-dismiss=\"alert\"><span aria-hidden=\"true\">&times;</span></button>" + k + " " + v + "</div>";
        }).join("") : "<div class='alert alert-danger text-center'>Неизвестная ошибка</div>";
        if($('.modal form').length)
            $('.modal .modal-footer').html(error_messages);
        else
            $("#notification").html(error_messages);
    })

    window.setTimeout(function() { $(".alert").alert('close'); }, 5000);
    $('.panel .panel-heading').on("click", function (e) {
        var el = $(this).find('span')
        if (el.hasClass('panel-collapsed')) {
            // expand the panel
            el.parents('.panel').find('.panel-body').slideDown();
            el.removeClass('panel-collapsed');
            el.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
        }
        else {
            // collapse the panel
            el.parents('.panel').find('.panel-body').slideUp();
            el.addClass('panel-collapsed');
            el.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
        }
    });

    var sec = new EventSource('/asset_prices/security')
    sec.addEventListener('update', function(response){
        console.log(response.data)
        post = jQuery.parseJSON(response.data)
        if($('table#security tbody tr').length > 4) $('table#security tbody tr:last-child').remove()
        $('table#security tbody ').prepend('<tr><td>' + post[0] + '</td><td>' + post[1] + '</td></tr>')
    })
    /*
    var fx = new EventSource('/asset_prices/fx')
    fx.addEventListener('update', function(response){
        post = jQuery.parseJSON(response.data)
        if($('table#fx tbody tr').length > 4) $('table#fx tbody tr:last-child').remove()
        $('table#fx tbody ').prepend('<tr><td>' + post[0] + '</td><td>' + post[1] + '</td></tr>')
    })*/

});



