# -*- coding: utf-8; -*-
#
# scraping renzaburo.jp
#
require 'nokogiri'
require 'open-uri'
require 'pathname'

class Renzaburo
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
			text = get_content( uri, book_title )
			yield( {id: Pathname( uri.path ).dirname.basename.to_s, uri: uri, text: text} )
		end
	end

	def get_content( uri, book_title = '' )
		text = ''
		html = open( uri, 'r:CP932', &:read ).encode( 'UTF-8' )
		html = html.gsub( /\&mdash;/, "\u2500" ).gsub( /\&quot;/, "\u201D" )
		(Nokogiri( html ) / 'div#mainContent' ).each do |content|
			(content / 'h3').each do |t|
				title = t.text.sub( /^『#{book_title}』　/, '' )
				text << "\n　　　　　#{title}\n\n"
			end
			(content / 'div.textBlock p' ).each do |para|
				next if /＜次回につづく＞/ =~ para.text
				text << '　' * 10 if (para.attr('class') || '').index( 'txtAlignC' )
				text << para.text.gsub( /<br>/, "\n" ) << "\n\n"
			end
		end
		text << "［＃改ページ］\n"
		text.gsub( /＜/, '〈' ).gsub( /＞/, '〉' )
	end
end
