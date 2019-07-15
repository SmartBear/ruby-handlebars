ruby-handlebars changelog
=========================

0.2.0 (unreleased)
------------------

 - add "unless" helper
 - add "helperMissing" helper, called when a helper is missing
 - "else" keyword is now handled by the parser directly

0.1.1 (2019/6/26)
------------------

 - with_temporary_context returns the result produced by the block

0.1.0 (2019/6/26)
-----------------

 - add 'with_temporary_context' in context to define temporary variables
 - enable @index, @first and @last variables in "each" helper (https://github.com/vincent-psarga/ruby-handlebars/pull/10 - @schuetzm)
 - allow specifying escaper when using double curly braces
 - allow using helper calls as arguments (https://github.com/vincent-psarga/ruby-handlebars/pull/11 - @schuetzm)
 - escape trice-braces replacements (https://github.com/vincent-psarga/ruby-handlebars/pull/9 - @schuetzm)
 - allow non-hash data (https://github.com/vincent-psarga/ruby-handlebars/pull/8 - @mvz)
 - allow single curly braces in content (https://github.com/vincent-psarga/ruby-handlebars/pull/7 - @mvz)
 - allow empty literal string arguments (https://github.com/vincent-psarga/ruby-handlebars/pull/6 - @mvz)
