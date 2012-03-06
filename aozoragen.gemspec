# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aozoragen/version"

Gem::Specification.new do |s|
  s.name        = "aozoragen"
  s.version     = Aozoragen::VERSION
  s.authors     = ["TADA Tadashi"]
  s.email       = ["t@tdtds.jp"]
  s.homepage    = "https://github.com/tdtds/aozoragen"
  s.summary     = "Generating AOZORA format text of eBook novels via some Web sites."
  s.description = "Scraping some Ebook web site and generating AOZORA format text files."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "nokogiri"
end
