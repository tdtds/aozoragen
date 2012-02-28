# -*- coding: utf-8; -*-
#
# scraping webmysteries.jp
#
require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'cgi'

module Aozoragen
	class Webmysteries
		def initialize( index_uri )
			@index_uri = URI( index_uri )
			@index_html = Nokogiri( open( @index_uri, 'r:UTF-8', &:read ) )
		end
	
		def metainfo
			info = {:id => Pathname( @index_uri.path ).basename.sub( %r|.*?-(.*)$|, '\1' ).to_s}
			info[:title] = (@index_html / '#wiki-body h1')[0].text
			(@index_html / '#wiki-body h2 + ul li' ).each do |li|
				info[:author] = [li.text]
			end
			info
		end
	
		def each_chapter
			(@index_html / '#wiki-body h3 + ul li a' ).each_with_index do |a, i|
				uri = URI( a.attr( 'href' ) )
				text = "\n"
				each_pages( uri ) do |page|
					text << page
				end
				yield( {id: '%02d' % (i+1), uri: uri, text: text} )
			end
		end
	
		def each_pages( index )
			begin
				pages = []
				html = Nokogiri( open( index, 'r', &:read ) )
				(html / 'ul.pageNavi a').each do |a|
					pages << a.attr( 'href' )
				end
				pages.shift	# delete current page
				begin
					(html / 'noscript param[name="FlashVars"]')[0].attr( 'value' ).scan( /entry=(\d+)/ ) do |i|
						yield get_text( i[0] )
					end
				end while html = Nokogiri( open( pages.shift, 'r', &:read ) )
			rescue TypeError
				# ignore open nil
			end
		end
	
		def get_text( xml_id )
			result = ''
			open( "http://www.webmysteries.jp/entry_xml_data/#{xml_id}.xml" ) do |fx|
				CGI::unescape( fx.read ).scan( %r|<entryBody>(.*?)</entryBody>|m ) do |entry|
					result << entry[0].gsub( %r|<.*?>|m, "" )
				end
			end
			result.
				gsub( /^.*（つづく）.*$/, '［＃改ページ］' ).
				gsub( /(?<=.)（([あ-ん]+)）/, '《\1》' ).
				gsub( /‐/, '─' ).
				gsub( /\uFF0D/, '─' ).
				gsub( /\n{3,}/m, "\n\n" )
		end
	end
end
