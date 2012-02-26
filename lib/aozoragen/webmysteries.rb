# -*- coding: utf-8; -*-
#
# scraping webmysteries.jp
#
require 'nokogiri'
require 'open-uri'
require 'pathname'

class Webmysteries
	def initialize( index_uri )
		@index_uri = URI( index_uri.to_s.sub( /index\.html$/, '' ) )
		@index_html = Nokogiri( open( @index_uri, 'r:CP932', &:read ) )
	end
end
