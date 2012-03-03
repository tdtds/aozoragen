# -*- coding: utf-8; -*-
#
# utility methods for converting to AOZORA format
#
require 'nokogiri'

##
# Enhanced String methods for converting to AOZORA format
# 
class String
	##
	# Half width of Alphabet and Digit to Full width.
	#
	def han2zen
		self.tr( 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
			'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ０１２３４５６７８９' )
	end

	##
	# replace characters fitting to vertical lyout
	#
	def for_tategaki
		self.tr( '＜＞−', '∧∨‐' ).han2zen
	end

	##
	# section heading format of Aozora
	#
	def subhead
		self.split( /\n/ ).map{|x|
			"\n［＃小見出し］#{x}［＃小見出し終わり］"
		}.join + "\n\n"
	end

	##
	# normalize invalid charcters
	#
	def normalize_char
		self.tr(
			"\u301d\u301f\u5699\u9830\u525d\u7626\u6451\u5653\u7e6b\uFF0D/",
			"〃”噛頬剥痩掴嘘繋─"
		)
	end
end

module Aozoragen
	##
	# Utility methods for Aozora format
	#
	module Util
		##
		# delete HTML tags
		#
		def detag( elem )
			# ruby tags
			(elem / 'ruby rp').each do |rp|
				case rp.text
				when '（'
					rp.inner_html = '《'
				when '）'
					rp.inner_html = '》'
				end
			end

			# delete tgas
			elem.to_html.
				gsub( /<br>/, "\n" ).
				gsub( /<.*?>/, '' ).
				strip
		end
	end
end
