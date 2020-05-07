ruby-handlebars changelog
=========================

[Unreleased]
------------

 - Faster parsing ([#26](https://github.com/SmartBear/ruby-handlebars/pull/26) - [@mvz])

[0.4.0] (2019/10/22)
--------------------

 - Allow slash character in partial names ([#18](https://github.com/SmartBear/ruby-handlebars/pull/18) - [@d316])
 - Add parameters for partials ([#19](https://github.com/SmartBear/ruby-handlebars/pull/19) [#20](https://github.com/SmartBear/ruby-handlebars/pull/20) - [@d316])

[0.3.0] (2019/10/11)
--------------------

 - Support helpers with "as" notation (`{{each items as |item|}}`)

[0.2.1] (2019/8/30)
-------------------

 - allow "else" word as being part of a path (eg: {{ my.something.else }} is okay)

[0.2.0] (2019/8/30)
-------------------

 - allow dash in identifiers ([#15](https://github.com/SmartBear/ruby-handlebars/pull/15) - [@stewartmckee])
 - add "unless" helper
 - add "helperMissing" helper, called when a helper is missing
 - "else" keyword is now handled by the parser directly

[0.1.1] (2019/6/26)
-------------------

 - with_temporary_context returns the result produced by the block

[0.1.0] (2019/6/26)
-------------------

 - add 'with_temporary_context' in context to define temporary variables
 - enable @index, @first and @last variables in "each" helper ([#10](https://github.com/SmartBear/ruby-handlebars/pull/10) - [@schuetzm])
 - allow specifying escaper when using double curly braces
 - allow using helper calls as arguments ([#11](https://github.com/SmartBear/ruby-handlebars/pull/11) - [@schuetzm])
 - escape trice-braces replacements ([#9](https://github.com/SmartBear/ruby-handlebars/pull/9) - [@schuetzm])
 - allow non-hash data ([#8](https://github.com/SmartBear/ruby-handlebars/pull/8) - [@mvz])
 - allow single curly braces in content ([#7](https://github.com/SmartBear/ruby-handlebars/pull/7) - [@mvz])
 - allow empty literal string arguments ([pr6]https://github.com/SmartBear/ruby-handlebars/pull/6) - [@mvz])

<!-- Contributors lists -->
[@stewartmckee]:  https://github.com/stewartmckee
[@schuetzm]:      https://github.com/schuetzm
[@mvz]:           https://github.com/mvz
[@d316]:          https://github.com/d316

<!-- Releases diffs -->
[Unreleased]: https://github.com/smartbear/ruby-handlebars/compare/v0.4.0...master
[0.4.0]:      https://github.com/smartbear/ruby-handlebars/compare/v0.3.0...v0.4.0
[0.3.0]:      https://github.com/smartbear/ruby-handlebars/compare/v0.2.1...v0.3.0
[0.2.1]:      https://github.com/smartbear/ruby-handlebars/compare/v0.2.0...v0.2.1
[0.2.0]:      https://github.com/smartbear/ruby-handlebars/compare/v0.1.1...v0.2.0
[0.1.1]:      https://github.com/smartbear/ruby-handlebars/compare/v0.1.0...v0.1.1
[0.1.0]:      https://github.com/smartbear/ruby-handlebars/compare/v0.0.6...v0.1.0
