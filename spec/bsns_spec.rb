require 'bsns'

BSNS.configure :content_path => File.dirname(__FILE__) + '/fixtures/sample_content'

class Buzzle < BSNS::Base

	attr_accessor :name, :age, :alignment

	has_many :buzzles, :as => :friendships, :with => :years
	has_many :fizzles
	has_many :fizzles, :as => :enemies,  :with => :reason
	has_many :fizzles, :as => :opinions, :with => :opinion
	has_one  :cat, :embedded => true
	has_many :fizzles, :as => :embedded_fizzles, :embedded => true
	has_one  :wizzle, :embedded => :true

end

class Wizzle < BSNS::Base

	attr_accessor :name, :powers, :species, :weaknesses

	acts_as_collection

	has_one :fizzle

end

class Fizzle < BSNS::Base
	
	attr_accessor :name

	content_path 'custom_dir_for_fizzles'

	has_many :fizzles

	has_many :cats, :embedded => true

end

class Cat < BSNS::Base

	attr_accessor :thing

end

describe BSNS do

	it "should load from content_directory" do
		buzz = Buzzle.load 'buzz'
		buzz.name.should == "Buzz Buzz Buzz"
		buzz.age.should  == 25
	end

	it "should load data from custom content_directory" do
		fizz = Fizzle.load 'fizz'
		fizz.name.should == 'Fizzy Fizz'
	end

	it "should load default associations" do
		buzz = Buzzle.load 'buzz'
		buzz.fizzles.length.should  == 2
		buzz.fizzles[0].name.should == "Fazzy Fazz Fazz"
		buzz.fizzles[1].name.should == "Fuzzy Wuzzy"
	end

	it "should load self-referential associations" do
		fizz = Fizzle.load 'fizz'
		fizz.fizzles.length.should  == 1
		fizz.fizzles[0].name.should == "Fazzy Fazz Fazz"
	end

	it "should load embedded has_one associations" do
		buzz = Buzzle.load 'buzz'
		buzz.cat.thing.should == 'tiedye shirts'
	end

	it "should load self-referential associations with extra keys" do
		buzz = Buzzle.load 'buzz'
		buzz.friendships.length.should   == 2
		buzz.friendships[1].name.should  == 'Bizzy Bizz Bizz'
		buzz.friendships[0].name.should  == 'Bazzy Bazz Bazz'
		buzz.friendships[1].years.should == 4
		buzz.friendships[0].years.should == 5
	end

	it "should load foreign associations with custom name" do
		buzz = Buzzle.load 'buzz'
		buzz.enemies.length.should  == 2
		buzz.enemies[0].name.should == 'Fizzy Fizz'
	end

	it "should load foreign associations with extra linking field" do
		buzz = Buzzle.load 'buzz'
		buzz.enemies[0].reason.should == "Wasn't fizzy enough; ruined soda."
		buzz.enemies[1].reason.should == "Got all over the rest of the clothes in the dryer."
	end

	it "should load associations in key/value hash form" do
		buzz = Buzzle.load 'buzz'
		buzz.opinions.length.should == 1
		buzz.opinions[0].opinion.should == "Hasn't done anything particularly annoying, yet."
	end

	it "should load defaults from the _defaults.yml file" do
		buzz = Buzzle.load 'buzz'
		buzz.alignment.should == "lawful neutral"
	end

	it "should allow for overrides of default values" do
		bizz = Buzzle.load 'bizz'
		bizz.alignment.should == "chaotic neutral"
	end

	it "should load an item from a single-file collection" do
		wizz = Wizzle.load 'wizzy'
		wizz.name.should == "Whizz"
		wizz.powers.length.should == 1
		wizz.weaknesses.length.should == 1
	end

	it "should preload defaults from a single-file collection" do
		wizz = Wizzle.load 'wizzy'
		wizz.species.should == "human"
	end

	it "should allow override of preloaded defaults" do
		wuzz = Wizzle.load 'wuzzy'
		wuzz.species.should == "horse"
	end

	it "should allow for embedded collections" do
		fazz = Fizzle.load 'fazz'
		fazz.cats.length.should   == 2
		fazz.cats[0].thing.should == 'whiskers'
		fazz.cats[1].thing.should == 'hats'
	end

	it "should load one has_many item as an array" do
		fuzz = Fizzle.load 'fuzz'
		fuzz.cats.length.should == 1
		fuzz.cats[0].thing.should == 'bad breath'
	end

	it "should handle associations of embedded associations" do
		buzz = Buzzle.load 'buzz'
		buzz.embedded_fizzles.length.should  == 1
		buzz.embedded_fizzles[0].name.should == "Embedded Fizzle"
		cats = buzz.embedded_fizzles[0].cats
		cats.length.should == 2
		cats[0].thing.should == 'poops a lot'
		cats[1].thing.should == 'sharp claws'
	end

	it "should handle embedded associations for has_one links" do
		buzz = Buzzle.load 'buzz'
		fizzle = buzz.wizzle.fizzle
		fizzle.name.should == "Fuzzy Wuzzy"
		fizzle.cats.length.should == 1
	end

end