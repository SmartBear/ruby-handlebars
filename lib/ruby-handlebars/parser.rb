require 'parslet'

module Handlebars
  class Parser < Parslet::Parser
    rule(:space)       { match('\s').repeat(1) }
    rule(:space?)      { space.maybe }
    rule(:dot)         { str('.') }
    rule(:gt)          { str('>')}
    rule(:hash)        { str('#')}
    rule(:slash)       { str('/')}
    rule(:ocurly)      { str('{')}
    rule(:ccurly)      { str('}')}

    rule(:docurly)     { ocurly >> ocurly }
    rule(:dccurly)     { ccurly >> ccurly }

    rule(:identifier)  { match['a-zA-Z0-9_\?'].repeat(1) }
    rule(:path)        { identifier >> (dot >> identifier).repeat }

    rule(:nocurly)     { match('[^{}]') }
    rule(:eof)         { any.absent? }
    rule(:template_content) {
      (
        ocurly >> nocurly | # Opening curly that doesn't start a {{}}
        ocurly >> eof     | # Opening curly that doesn't start a {{}} because it's the end
        ccurly            | # Closing curly that is not inside a {{}}
        nocurly
      ).repeat(1).as(:template_content) }

    rule(:replacement) { docurly >> space? >> path.as(:replaced_item) >> space? >> dccurly}
    rule(:safe_replacement) { ocurly >> replacement >> ccurly }

    rule(:sq_string)   { match("'") >> match("[^']").repeat.maybe.as(:str_content) >> match("'") }
    rule(:dq_string)   { match('"') >> match('[^"]').repeat.maybe.as(:str_content) >> match('"') }
    rule(:string)      { sq_string | dq_string }

    rule(:parameter)   { (path | string).as(:parameter_name) }
    rule(:parameters)  { parameter >> (space >> parameter).repeat }

    rule(:unsafe_helper) { docurly >> space? >> identifier.as(:helper_name) >> (space? >> parameters.as(:parameters)).maybe >> space? >> dccurly}
    rule(:safe_helper) { ocurly >> helper >> ccurly }

    rule(:helper) { unsafe_helper | safe_helper }

    rule(:block_helper) {
      docurly >>
      hash >>
      identifier.capture(:helper_name).as(:helper_name) >>
      (space >> parameters.as(:parameters)).maybe >>
      space? >>
      dccurly >>
      scope {
        block
      } >>
      dynamic { |src, scope|
        docurly >> slash >> str(scope.captures[:helper_name]) >> dccurly
      }
    }

    rule(:partial) {
      docurly >>
      gt >>
      space? >>
      identifier.as(:partial_name) >>
      space? >>
      dccurly
    }

    rule(:block) { (template_content | replacement | safe_replacement | helper | partial | block_helper ).repeat.as(:block_items) }

    root :block
  end
end
