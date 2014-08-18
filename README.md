# Aozoragen
Web上の小説を青空文庫形式のテキストにする。

## How to install
Gemを使ってインストールする:

    gem install aozoragen

## Command-line syntax
### aozoragen
指定されたWebサイトをスクレイピングして、青空文庫形式のテキストファイルを生成する。

    % aozoragen <URL>

`URL`には日本語の小説をHTML形式で配布しているサイトの目次ページを指定する。カレントディレクトリに章ごとのテキストファイル(拡張子.txt)を生成する。ファイル名はサイトごとに自動的に決定され、`hoge.NN.txt` (NNは連番数値またはその他の文字列)のような形式となる。これらのファイルを連結すると一冊の本になる。

`aozoragen`コマンドが現在対応しているのは以下のサイト:

* 最前線 <http://sai-zen-sen.jp/>
 * 指定例: http://sai-zen-sen.jp/fictions/marginaloperation/
 * 実行時に無償公開中の章のみが抽出される。
* レンザブロー <http://renzaburo.jp/>
 * 指定例: http://renzaburo.jp/contents_t/061-katano/index.html
* 小説を読もう! <http://yomou.syosetu.com/>
 * 指定例: http://ncode.syosetu.com/n8725k/
* Webミステリーズ! <http://www.webmysteries.jp/>
 * Webミステリーズ!の掲載作品には目次ページがないため、GitHubのWikiで代用する。
 * h1要素に書名、h2要素に続くリストで著者名、h3要素に続くリストで連載各回のURLを表現する。
 * WikiページのURLは、ファイル名が「webmysteries-」で始まるようにする。
 * 指定例: https://github.com/tdtds/aozoragen/wiki/webmysteries-mm9_destruction

### aozora2pdf
[青空キンドル](http://a2k.aill.org/)を使ってテキストをKindle向けPDFにする。パラメタにはaozoragenで生成した青空文庫形式のテキストファイルを順番通りに指定する。PDFは標準出力に出るので、リダイレクトする:

    % aozora2pdf hoge*.txt > hoge.pdf

## 注意
Web上に公開されている小説は著作権の保護下にある。ダウンロードしたテキストは個人の利用のみにとどめ、決して再配布・公衆送信などをしてはいけない。読みやすく加工しやすいHTML形式で小説を公開してくれている各サービスおよび著者の方々に感謝を。
