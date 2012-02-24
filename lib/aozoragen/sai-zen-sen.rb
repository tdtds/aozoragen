# -*- coding: utf-8; -*-
#
# scraping sai-zen-sen.jp
#
require 'nokogiri'
require 'open-uri'
require 'pathname'

class SaiZenSen
	def initialize( index_uri )
		if index_uri.path == '/sa/fate-zero/works/'
			@entity = SaiZenSenFateZero::new( index_uri )
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
			chapter = Nokogiri( open( uri, 'r:utf-8', &:read ) )
			text = ''
			(chapter / 'section.book-page-spread').each do |page|
				page.children.each do |section|
					case section.name
					when 'hgroup'
						text << "\n［＃小見出し］#{detag section}［＃小見出し終わり］\n\n"
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

			yield( {id: Pathname( uri.path ).dirname.basename.to_s, uri: uri, text: text} )
		end
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
		elem.to_html.gsub( /<.*?>/, '' ).strip
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
