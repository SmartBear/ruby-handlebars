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

    rule(:identifier)  { match['a-zA-Z0-9_'].repeat(1) }
    rule(:path)        { identifier >> (dot >> identifier).repeat }

    rule(:template_content) { match('[^{}]').repeat(1).as(:content) }

    rule(:replacement) { docurly >> space? >> path.as(:item) >> space? >> dccurly}
    rule(:safe_replacement) { ocurly >> replacement >> ccurly }

    rule(:sq_string)   { match("'") >> match("[^']").repeat(1).as(:content) >> match("'") }
    rule(:dq_string)   { match('"') >> match('[^"]').repeat(1).as(:content) >> match('"') }
    rule(:string)      { sq_string | dq_string }

    rule(:parameter)   { (path | string).as(:parameter_name) }
    rule(:parameters)  { parameter >> (space >> parameter).repeat }

    rule(:helper) { docurly >> space? >> identifier.as(:helper_name) >> (space? >> parameters.as(:parameters)).maybe >> space? >> dccurly}

    rule(:partial) {
      docurly >> 
      gt >> 
      space? >>
      identifier.as(:partial_name) >>
      space? >>
      dccurly
    }

    rule(:each_block) {
      docurly >>
      str('#each') >>
      space >>
      (
        identifier.as(:itered_item_name) >>
        space >>
        str('in') >>
        space
      ).maybe >>
      path.as(:itered_items) >>
      space? >>
      dccurly >>
      block.as(:iteration_block) >>
      docurly >>
      str('/each') >>
      dccurly
    }

    rule(:else_kw) {str('else')}
    rule(:if_block) {
      docurly >>
      str('#if') >>
      space >>
      path.as(:condition) >>
      space? >>
      dccurly >>
      block.as(:if_body) >>
      (
        docurly >>
        else_kw >>
        dccurly >>
        block.as(:else_body)
      ).maybe >>
      docurly >>
      str('/if') >>
      dccurly
    }

    rule(:block) { (template_content | replacement | safe_replacement | helper | partial | each_block | if_block ).repeat }

    root :block
  end
end