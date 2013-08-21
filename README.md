![BSNS](logo.gif)

---

[![Build Status](https://secure.travis-ci.org/Yuffster/BSNS.png)](http://travis-ci.org/Yuffster/BSNS)

---

\* Techie translation: BSNS is a simple YAML content store to allow your boss to
tweak the website himself just by using a text editor.  Assuming you then keep
all of those changes in version control, you end up with a log of all changes
and who was responsible for them.

# Let's say you work at a sandwich shop.

Your boss, Jim, he's a genius.  A true sandwich artist.  He spends a lot of time
making up new sandwiches, or tweaking the old classics.  Really, he doesn't get
that many customers, so he has a lot of free time on his hands.

He wants you to make a new website for the restaurant, one that's dynamic and
changes as often as the menu does.

"No problem," you say.  "Gimme a couple of weeks and a ton of Mountain Dew." 

## So you start to use BSNS.

### Installation

Installation is dead-simple, you just type:

`gem install bsns`

And for good measure, you add this line to your Gemfile:

`gem 'bsns'`

### Configuration

Now you just make a new directory in your app root called "bsns_content" and
add this line of code somewhere in your initialization scripts (those are the
scripts that load when your application loads).

```ruby
require 'bsns'
BSNS.configure :content_path => File.dirname(__FILE__) + 'bsns_content'
```

### Models

Now you make a model for sandwiches.  It looks something like this:

```ruby
class Sandwich < BSNS::Base

	attr_accessor :name, :description

	has_many :ingredients, :with => :amount

end
```

For each sandwich that Jim creates, you tell him to add a file within
bsns_content/sandwiches.

For example, the ham sandwich might end up in bsns_content/sandwiches/ham.yml,
and might look something like this:

### YAML Format

```yml
title: Ham Sandwich
description: Breakfast on a bun!  This ham sandwich features seasoned eggs, the
finest slices of American cheese, and a dash of olive oil on a wheat roll.
ingredients:
  ham: 2
  american_cheese: 2
  scrambled_egg: 2
  olive_oil: 1
  avocado: .5
```

### Collections

And you make a second model for Ingredients, which you're fine placing all into
one file.

```ruby
class Ingredient < BSNS::Base

	acts_as_collection

	attr_accessor :name, :cost

end
```

Your YML file (`bsns_content/ingredients.yml`) might look something like this:

```yaml
american_cheese: 
  title: American Cheese
  cost: 5
  description: a slice of American cheese
  calories: 50
ham:
  title: Thickly-sliced Ham
  cost: 68
  description: Some people would call it Canadian bacon.
  calories: 100
scrambled_egg:
  name: Scrambled Eggs
  cost: 42
  description: jumbo Grade-A egg, scrambled with salt, chives, and a touch of butter.
  calories: 50
wheat_roll:
  name: Wheat Roll
  cost: 15
  description: a freshly-baked wheat roll
  calories: 60
olive_oil:
  name: Olive Oil
  cost: 5
  description: a dash of olive oil
  calories: 20
avocado:
  name: Avocado
  cost: 100
  description: Premium California Haas Avocados, grown by a mystical race of green-thumbed gnomes who work for candy corn instead of wages.
  calories: 600
banana:
  name: Banana
  cost: 18
  description: A full banana.
honey:
  name: Honey
  cost: 4
  description: A spread of honey.
peanut_butter:
  name: Peanut Butter (smooth)
  cost: 20
  description: A spread of peanut butter.
```

### Default Values

Now you can do fun stuff with your models.  Let's add a method to Sandwich to
automatically price sandwiches at a 150% markup.

```ruby
class Sandwich < BSNS::Base

	def price
	    total = 0
		ingredients.each do |i|
		  total = total + i.cost*i.amount
		end
		total * 1.5
	end

end
```

But this puts you in the position where you're responsible for changing the
code every time Jim wants to tweak the margin on sandwiches!  Plus, what happens when you end up with a crate full of bananas and nobody's touching the PB&B sandwiches?

What if we made it possible for Jim to set a sound *default* price modifier for
all sandwiches, and then let him override those defaults later?  (Yes, I know,
this sounds an awful lot like programming, but don't let Jim know that or he'll
realize he doesn't need you to be his web developer).

You'd give Jim a new YML file called `sandwiches/_defaults.yml`.  It's what it
says on the tin: default values for all sandwiches.

```yaml
price_modifier: 1.5
description: No description available. :(
```

And add a new sandwich file, `sandiwches/pbnb.yml`:

```yaml
title: Peanut Butter and Banana
ingredients:
  banana: 1
  peanut_butter: 1
  honey: 1
price_modifier: .5
```

Now, we can change our code to:

```ruby
class Sandwich < BSNS::Base

	attr_accessor :price_modifier

	def price
	    total = 0
		ingredients.each do |i|
		  total = total + i.cost*i.amount
		end
		total * price_modifier
	end

end
```