(function($){

// 最初に訪れた際に実行
$(document).on('pageinit', function(){
});

// 【使い方】を開いたときに実行
$('#usage').live('pageinit', function(e, d){
});

// 【アイコン作成】を開いたときに実行
$('#icon-maker').live('pageinit', function(e, d){

    $('#waim-icon-url').addClass('ui-disabled');
    $('#waim-open').data('link', '').addClass('ui-disabled');

    // サイトのリストを選ぶとアドレスを取得する
    $('#waim-site').on('change', function(e) {
        var $target = $(e.target)
            ,name = $target.val()
        ;

        $('#waim-open').data('link', '').addClass('ui-disabled');

        if (name == 'custom') {
            $('#waim-site-url').val('http://');
        } else {
            $.getJSON('/getUrl', {site: name}, function(data) {
                $('#waim-site-url').val(data.result);
            });
        }
    }).trigger('change');

    // 【詳細設定】のボタンでフォームを開閉する
    $('#waim-toggle-setting').on('change', function(e) {
        var $target = $(e.target);

        if ($target.val() == 'off') {
            $('#waim-detail-setting').fadeOut();
        } else {
            $('#waim-detail-setting').fadeIn();
        }
    });

    // jQuery Mobile の要素が出来上がってから最初の一回を実行
    window.setTimeout(function(){
        $('#waim-detail-setting').hide();
    }, 200);

    // 【アイコンを指定する】チェックボックス
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

    // 【作成実行】
    $('#waim-make').on('click', function(e) {
        var url = $('form').attr('action');

        $.mobile.showPageLoadingMsg();
        $('#waim-make').addClass('ui-disabled');

        $('#waim-form').upload('/getAddress', function(data) {
            var decoded = data.result
                .replace(/&lt;/g, '<').replace(/&gt;/g, '>');

            $('#waim-open')
                .data('link', decoded)
                .removeClass('ui-disabled');
            ;

            $.mobile.hidePageLoadingMsg();
            $('#waim-make').removeClass('ui-disabled');

            window.alert('成功しました！'
                + '【リンクを開く】をタップして新しいウィンドウを開いた後、'
                + 'そのページを【ホーム画面に追加】してください。');
        }, 'json');

        return false;
    });

    // 【リンクを開く】
    $('#waim-open').on('click', function(e) {
        var link = $('#waim-open').data('link');

        if (link.length == 0) {
            return false;
        }

        window.open(link);

        return false;
    });
});

})(jQuery);
