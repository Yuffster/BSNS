Gem::Specification.new do |s|

	s.name        = "bsns"
	s.version     = "0.2.2"
	s.author      = "Michelle Steigerwalt"
	s.email       = "msteigerwalt@gmail.com"
	s.homepage    = "http://github.com/Yuffster/bsns"
	s.summary     = "Business-oriented Semantic Node Structures. (A simple YAML-based way for people to drop content and static data into your code's repository.)"
	s.description = "Static YAML assets which live in your application repositories.  For the streamlined modification of informational, promotional and business assets by non-technical personnel, providing project stake-holders with an unparalleled ability to efficiently allocate resources and expedite engineering man hours."

	s.files        = ["lib/bsns.rb", "spec/bsns_spec.rb", "Gemfile"]
	s.require_path = "lib"

	s.rubyforge_project = s.name
	
end
