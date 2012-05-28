# -*- coding: utf-8; -*-
#
# scraping renzaburo.jp
#
require 'aozoragen/util'
require 'open-uri'
require 'pathname'

module Aozoragen
	class Renzaburo
		include Util

		def initialize( index_uri )
			@index_uri = URI( index_uri.to_s.sub( /index\.html$/, '' ) )
			@index_html = Nokogiri( open( @index_uri, 'r:CP932', &:read ) )
		end
	
		def metainfo
			info = {:id => Pathname( @index_uri.path ).basename.to_s}
			(@index_html / 'title').each do |t|
				info[:title] = t.text.sub( /｜.*/, '' )
			end
			(@index_html / 'div.textBlock strong' ).each do |st|
				info[:author] = [st.text]
			end
			info
		end
	
		def each_chapter
			book_title = metainfo[:title]
			(@index_html / 'ul.btnList li.withDate a' ).each do |a|
				uri = @index_uri + a.attr( :href )
				get_content( uri, book_title ) do |u, t|
					text = t.normalize_char
					chap_id = "#{Pathname( u.path ).dirname.basename}-#{Pathname(u.path).basename('.html')}"
					yield( {id: chap_id, uri: u, text: text} )
				end
			end
		end
	
		def get_content( uri, book_title = '' )
			text, html = get_page_content( uri, book_title )
			yield uri, text

			[].tap{|urls|
				(html / 'ul.pageLink li a').each{|a| urls << (uri + a.attr( 'href' )) }
			}.sort.uniq.each do |uri|
				text, html = get_page_content( uri, book_title )
				yield uri, text
			end
		end

	private
		def get_page_content( uri, book_title )
			text = ''
			html = open( uri, 'r:CP932', &:read ).encode( 'UTF-8' )
			html = html.gsub( /\&mdash;/, "\u2500" ).gsub( /\&quot;/, "\u201D" )
			dom = Nokogiri( html )
			(dom / 'div#mainContent' ).each do |content|
				(content / 'h3').each do |t|
					text << t.text.sub( /^『#{book_title}』　/, '' ).subhead
				end
				(content / 'div.textBlock p' ).each do |para|
					next if /＜次回につづく＞/ =~ para.text
					text << '［＃１０字下げ］' if (para.attr('class') || '').index( 'txtAlignC' )
					text << para.text.gsub( /<br>/, "\n" ) << "\n\n"
				end
			end
			text << "［＃改ページ］\n"
			return [text.for_tategaki, dom]
		end
	end
end
