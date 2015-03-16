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


$(function() {
    return $("form#sign_in_client, form#sign_up_client").bind("ajax:success", function(event, xhr, settings) {
        window.location = '/';
    }).bind("ajax:error", function(event, xhr, settings, exceptions) {
        var error_messages;
        error_messages = xhr.responseJSON['error'] ? "<div class='alert alert-danger text-center'>" + xhr.responseJSON['error'] + "</div>" : xhr.responseJSON['errors'] ? $.map(xhr.responseJSON["errors"], function(v, k) {
            return "<div class='alert alert-danger text-center'>" + k + " " + v + "</div>";
        }).join("") : "<div class='alert alert-danger text-center'>Unknown error</div>";
        return $(this).parents('.modal').find('.modal-footer').html(error_messages);
    });
});

