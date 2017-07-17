# timetest

## サーバー時間変更テストフレームワーク　[プロトタイプ]

 * 現段階ではプロトタイプ。

 * サーバーの時間ごとで振る舞いをテストする
    * 例
       * cron設定されているプログラム
       * atコマンドで設定されているプログラム
       * 一定時間のWEBページの表示変更
   
 * 設定
    * conf/config.ymlにユーザー設定
    * 開始日時・終了日時・時間をすすめる間隔・テストするプログラム等
    * conf/hosts テストする対象サーバー設定
       * Ansibleの設定ファイルになる。

* 用法
   * ruby timetest.rb
   * option
      * --debug : デバッグモード
      * --config [config file]
      * --hosts [hosts file]
  







