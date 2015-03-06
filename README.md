ruby-handlebars
===============

[![Build Status](https://travis-ci.org/vincent-psarga/ruby-handlebars.svg?branch=master)](https://travis-ci.org/vincent-psarga/ruby-handlebars)
[![Code Climate](https://codeclimate.com/github/vincent-psarga/ruby-handlebars/badges/gpa.svg)](https://codeclimate.com/github/vincent-psarga/ruby-handlebars)
[![Test Coverage](https://codeclimate.com/github/vincent-psarga/ruby-handlebars/badges/coverage.svg)](https://codeclimate.com/github/vincent-psarga/ruby-handlebars)

Pure Ruby library for [Handlebars](http://handlebarsjs.com/) template system.
The main goal of this library is to simplify the use of Ruby and Handlebars on Windows machine. If you do not have any need of working on Windows, take a look at [handlebars.rb](https://github.com/cowboyd/handlebars.rb) that uses the real Handlebars library.

Installing
----------

Simply run:

```shell
gem install ruby-handlebars
```

No need for libv8, ruby-racer or any JS related tool.

Using
-----

A very simple case:

```ruby

require 'ruby-handlebars'

hbs = Handlebars::Handlebars.new
hbs.compile("Hello {{name}}").call({name: 'world'})
# Gives: "Hello world", how original ...
```

You can also use partials:

```ruby
hbs.register_partial('full_name', "{{person.first_name}} {{person.last_name}}")
hbs.compile("Hello {{> full_name}}").call({person: {first_name: 'Pinkie', last_name: 'Pie'}})
# Gives: "Hello Pinkie Pie"
```

You can also register inline helpers:

```ruby
hbs.register_helper('strip') {|context, value| value.strip}
hbs.compile("Hello {{strip name}}").call({name: '                       world     '})
# Will give (again ....): "Hello world"
```

or block helpers:

```ruby
hbs.register_helper('comment') do |context, commenter, block|
  block.fn(context).split("\n").map do |line|
    "#{commenter} #{line}"
  end.join("\n")
end

hbs.compile("{{#comment '//'}}My comment{{/comment}}").call
# Will give: "// My comment"
```

Note that in any block helper you can use an ``else`` block:

```ruby
hbs.register_helper('markdown') do |context, block, else_block|
  html = md_to_html(block.fn(context))
  html.nil? : else_block(context) : html
end

template = [
  "{{#markdown}}",
  "  {{ description }}",
  "{{else}}",
  "  Description is not valid markdown, no preview available",
  "{{/markdown}}"
].join("\n")

hbs.compile(template).call({description: my_description})
# Output will depend on the validity of the 'my_description' variable
```

Two default helpers are provided: ``each`` and ``if``. It is not yet possible to name the current item in an each loop and ``this`` must be used to reference it.

```ruby
template = [
  "{{#each items}}",
  "  {{{ this }}}",
  "{{else}}",
  "  No items",
  "{{/each}}",
  "",
  "{{#if my_condition}}",
  "  It's ok",
  "{{else}}",
  "  or maybe not",
  "{{/if}}",
].join("\n")
```

Limitations and roadmap
-----------------------

This gem does not reuse the real Handlebars code (the JS one) and not everything is handled yet (but it will be someday ;) ):

 - there is no escaping, all strings are considered as safe (so ``{{{ my_var }}}`` and ``{{ my_var }}``) will output the same thing
 - the parser is not fully tested yet, it may complain with spaces ...
 - curly bracket are __not__ usable in the template content yet. one workaround is to create simple helpers to generate them
 - parsing errors are, well, not helpful at all

 Aknowledgements
 ---------------

This gem would simply not exist if the handlebars team was not here. Thanks a lot for this awesome templating system.
Thanks a lot to @cowboyd for the [handlebars.rb](https://github.com/cowboyd/handlebars.rb) gem. We used it for a while and it's great (and as told at the beginning of the README, if you do not need any Windows support, use handlebars.rb instead ;) )
