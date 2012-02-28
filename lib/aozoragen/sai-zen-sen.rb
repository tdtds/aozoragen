# -*- coding: utf-8; -*-
#
# scraping sai-zen-sen.jp
#
require 'nokogiri'
require 'open-uri'
require 'pathname'

module Aozoragen
	class SaiZenSen
		def initialize( index_uri )
			case index_uri.path
			when '/sa/fate-zero/works/'
				@entity = SaiZenSenFateZero::new( index_uri )
			when %r|/01.html$| # short story
				@entity = SaiZenSenShort::new( index_uri )
			else
				@entity = SaiZenSenRegular::new( index_uri )
			end
		end
	
		def metainfo
			@entity.metainfo
		end
	
		def each_chapter
			@entity.each_chapter{|c| yield c}
		end
	
		def each_chapter_local( selector )
			(@index_html / selector).each do |a|
				uri = @index_uri + a.attr('href')
				next if uri.path == '/entryguide.html' # skipping member only contents.

				chapter = Nokogiri( open( uri, 'r:utf-8', &:read ) )
				text = get_chapter_text( chapter )
				yield( {id: Pathname( uri.path ).dirname.basename.to_s, uri: uri, text: text} )
			end
		end
	
		def get_chapter_text( chapter )
			text = ''
			(chapter / 'section.book-page-spread').each do |page|
				page.children.each do |section|
					case section.name
					when 'hgroup'
						text << detag( section ).split( /\n/ ).map{|x|
							"\n［＃小見出し］#{x}［＃小見出し終わり］"
						}.join
						text << "\n"
					when 'div'
						case section.attr( 'class' )
						when /delimiter/
							text << "［＃５字下げ］#{'─' * 10}\n\n"
						when /pgroup/
							(section / 'p').each do |paragraph|
								text << "　#{detag paragraph}\n"
							end
							text << "\n"
						else
							(section / 'div.pgroup').each do |div|
								(div / 'p').each do |paragraph|
									text << "　#{detag paragraph}\n"
								end
								text << "\n"
							end
						end
					end
				end
				text << "［＃改ページ］\n"
			end
			text
		end
	
		def detag( elem )
			(elem / 'ruby rp').each do |rp|
				case rp.text
				when '（'
					rp.inner_html = '《'
				when '）'
					rp.inner_html = '》'
				end
			end
			elem.to_html.
				gsub( /<br>/, "\n" ).
				gsub( /<.*?>/, '' ).
				gsub( /\u6451/, '掴' ).
				gsub( /\u5653/, '嘘' ).
				strip
		end
	end
	
	class SaiZenSenRegular < SaiZenSen
		def initialize( index_uri )
			@index_uri = index_uri
			@index_html = Nokogiri( open( @index_uri, 'r:utf-8', &:read ) )
		end
	
		def metainfo
			info = {:id => Pathname( @index_uri.path ).basename.to_s, :author => []}
			info[:title] = (@index_html / '#page-content-heading h1')[0].text
			(@index_html / '#authors h3').each do |author|
				info[:author] << author.text.sub( /.*? /, '' )
			end
			info
		end
	
		def each_chapter
			each_chapter_local( '#back-numbers li a' ){|c| yield c}
		end
	end
	
	class SaiZenSenShort < SaiZenSen
		def initialize( index_uri )
			@index_uri = index_uri
			@index_html = Nokogiri( open( @index_uri, 'r:utf-8', &:read ) )
		end
	
		def metainfo
			info = {:id => Pathname( @index_uri.path ).dirname.dirname.basename.to_s, :author => []}
			info[:title] = (@index_html / 'h1.book-title')[0].text
			(@index_html / 'h2.book-author strong').each do |author|
				info[:author] << author.text
			end
			info
		end
	
		def each_chapter
			text = get_chapter_text( @index_html )
			yield( {id: Pathname( @index_uri.path ).basename( '.html' ).to_s, uri: @index_uri, text: text} )
		end
	end
	
	class SaiZenSenFateZero < SaiZenSen
		def initialize( index_uri )
			@index_uri = index_uri
			@index_html = Nokogiri( open( @index_uri, 'r:utf-8', &:read ) )
		end
	
		def metainfo
			info = {
				:id => Pathname( @index_uri.path ).basename.to_s,
				:author => ['虚淵玄']
			}
			info[:title] = (@index_html / 'h1 img')[0].attr( 'alt' )
			info
		end
	
		def each_chapter
			each_chapter_local( 'article a' ){|c| yield c}
		end
	
	end
end
