# -*- coding: utf-8; -*-
#
# scraping sai-zen-sen.jp
#
require 'nokogiri'
require 'open-uri'
require 'pathname'

class SaiZenSen
	def initialize( index_uri )
		@index_uri = index_uri
		@index_html = Nokogiri( open( @index_uri, 'r:utf-8', &:read ) )
	end

	def metainfo
		info = {:id => Pathname( @index_uri.path ).basename.to_s}
		info[:title] = (@index_html / '#page-content-heading h1')[0].text
		(@index_html / '#authors h3').each do |author|
			info[:author] = (info[:author] || [] ) << author.text.sub( /.*? /, '' )
		end
		info
	end

	def each_chapter
		(@index_html / '#back-numbers li a').each do |a|
			uri = @index_uri + a.attr('href')
			chapter = Nokogiri( open( uri, 'r:utf-8', &:read ) )
			text = ''
			(chapter / 'section.book-page-spread').each do |page|
				page./( 'hgroup', 'div.pgroup' ).each do |section|
					case section.name
					when 'hgroup'
						text << "\n　　　　　#{detag section}\n\n"
					when 'div'
						if section.attr( 'class' ) =~ /delimiter/
							text << '　' * 5 << '─' * 10 << "\n"
						else
							section.children.each do |paragraph|
								next unless paragraph.name == 'p'
								text << "　#{detag paragraph}\n"
							end
						end
						text << "\n"
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
