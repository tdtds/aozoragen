# -*- coding: utf-8; -*-
#
# scraping yomou.syosetu.com
#
require 'aozoragen/util'
require 'open-uri'
require 'pathname'

class String
	def fix_aozora_notation
		self.gsub(/[｜|](.+?)『(.+?)』/){"｜#$1《#$2》"}
	end
end

module Aozoragen
	class Syosetu
		include Util

		def initialize(index_uri)
			@index_uri = index_uri
			@index_html = Nokogiri(open(@index_uri, 'r:utf-8', &:read))
		end
	
		def metainfo
			info = {:id => Pathname(@index_uri.path).basename.to_s, :author => []}
			info[:title] = (@index_html / 'title')[0].text
			info[:author] << (@index_html / '.novel_writername a')[0].text
			info
		end
	
		def each_chapter
			(@index_html / '.subtitle a').each do |a|
				uri = @index_uri + a.attr('href')

				chapter = Nokogiri(open(uri, 'r:utf-8', &:read).tr('《》．|', '『』・｜'))
				text = get_chapter_text(chapter)
				chapter_id = '%03d' % Pathname(uri.path).basename.to_s.to_i
				yield({id: chapter_id, uri: uri, text: text})
			end
		end

		def get_chapter_text(chapter)
			text = ''
			text << (chapter / '.novel_subtitle')[0].text.subhead
			(chapter / '#novel_honbun').each do |page|
				text << detag(page).gsub(/\n{2,5}/, "\n").gsub(/^　*◆$/, '［＃１０字下げ］◆')
				text << "［＃改ページ］\n"
			end
			text.han2zen.for_tategaki.fix_aozora_notation
		end
	end
end
