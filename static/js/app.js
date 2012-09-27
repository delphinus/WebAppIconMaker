(function($){

var sites = {
    'google-maps': {
        'site-url': 'https://maps.google.co.jp/'
    }
    ,'yahoo-maps': {
        'site-url': 'http://maps.loco.yahoo.co.jp/'
    }
};

$(document).on('pageinit', function(){
});

$('#top').live('pageinit', function(e, d){
});

$('#icon-maker').live('pageinit', function(e, d){
    $('#waim-icon-url').addClass('ui-disabled');
    $('#waim-address').addClass('ui-disabled');

    $('#waim-site').on('change', function(e) {
        var $target = $(e.target)
            ,name = $target.val()
            ,data = sites[name]
        ;

        if (data) {
            $('#waim-site-url').val(data['site-url']);
            $('#waim-icon-url').val(data['icon-url']);
        }
    }).trigger('change');

    $('#waim-use-icon').on('change', function(e) {
        var $target = $(e.target);

        if ($target.val() == 'off') {
            $('#waim-icon-url')
                .addClass('ui-disabled')
                .parentsUntil('div[data-role=fieldcontain]')
                .fadeOut();
        } else {
            $('#waim-icon-url')
                .removeClass('ui-disabled')
                .parentsUntil('div[data-role=fieldcontain]')
                .fadeIn();
        }
    });

    window.setTimeout(function(){
            $('#waim-icon-url')
                .addClass('ui-disabled')
                .parentsUntil('div[data-role=fieldcontain]')
                .fadeOut();
    }, 200);

    $('#waim-make').on('click', function(e) {
        var url = $('form').attr('action')
            ,param = $('form').serialize()
        ;

        $.mobile.showPageLoadingMsg();

        $.getJSON(url + '?' + param, function(data) {
            $('#waim-address')
                .text(data.result)
                .css({height: $('#waim-address').scrollHeight})
                .removeClass('ui-disabled')
            ;

            $.mobile.hidePageLoadingMsg();

            window.alert('成功しました！'
                + '作成されたアドレスを選択してコピーした後、'
                + 'アドレスバーに貼り付けてください。');
        });

        return false;
    });
});

})(jQuery);
