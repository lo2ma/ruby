require 'rdoc/test_case'

class TestAttributeManager < RDoc::TestCase # HACK fix test name

  def setup
    super

    @options = RDoc::Options.new

    @am = RDoc::Markup::AttributeManager.new
    @klass = RDoc::Markup::AttributeManager
    @formatter = RDoc::Markup::Formatter.new @options
    @formatter.add_tag :BOLD, '<B>', '</B>'
    @formatter.add_tag :EM, '<EM>', '</EM>'
    @formatter.add_tag :TT, '<CODE>', '</CODE>'
  end

  def test_convert_attrs_ignores_code
    assert_equal 'foo <CODE>__send__</CODE> bar', output('foo <code>__send__</code> bar')
  end

  def test_convert_attrs_ignores_tt
    assert_equal 'foo <CODE>__send__</CODE> bar', output('foo <tt>__send__</tt> bar')
  end

  def test_convert_attrs_preserves_double
    assert_equal 'foo.__send__ :bar', output('foo.__send__ :bar')
    assert_equal 'use __FILE__ to', output('use __FILE__ to')
  end

  def test_convert_attrs_does_not_ignore_after_tt
    assert_equal 'the <CODE>IF:</CODE><EM>key</EM> directive', output('the <tt>IF:</tt>_key_ directive')
  end

  def test_initial_word_pairs
    word_pairs = @am.matching_word_pairs
    assert word_pairs.is_a?(Hash)
    assert_equal(3, word_pairs.size)
  end

  def test_initial_html
    html_tags = @am.html_tags
    assert html_tags.is_a?(Hash)
    assert_equal(5, html_tags.size)
  end

  def test_add_matching_word_pair
    @am.add_word_pair("x","x", :TEST)
    word_pairs = @am.matching_word_pairs
    assert_equal(4,word_pairs.size)
    assert(word_pairs.has_key?("x"))
  end

  def test_add_invalid_word_pair
    assert_raises ArgumentError do
      @am.add_word_pair("<", "<", :TEST)
    end
  end

  def test_add_word_pair_map
    @am.add_word_pair("x", "y", :TEST)
    word_pair_map = @am.word_pair_map
    assert_equal(1,word_pair_map.size)
    assert_equal(word_pair_map. keys.first.source, "(x)(\\S+)(y)")
  end

  def test_add_html_tag
    @am.add_html("Test", :TEST)
    tags = @am.html_tags
    assert_equal(6, tags.size)
    assert(tags.has_key?("test"))
  end

  def test_add_special
    @am.add_special "WikiWord", :WIKIWORD
    specials = @am.special

    assert_equal 1, specials.size
    assert specials.assoc "WikiWord"
  end

  def test_escapes
    assert_equal '<CODE>text</CODE>',   output('<tt>text</tt>')
    assert_equal '<tt>text</tt>',       output('\\<tt>text</tt>')
    assert_equal '<tt>',                output('\\<tt>')
    assert_equal '<CODE><tt></CODE>',   output('<tt>\\<tt></tt>')
    assert_equal '<CODE>\\<tt></CODE>', output('<tt>\\\\<tt></tt>')
    assert_equal '<B>text</B>',         output('*text*')
    assert_equal '*text*',              output('\\*text*')
    assert_equal '\\',                  output('\\')
    assert_equal '\\text',              output('\\text')
    assert_equal '\\\\text',            output('\\\\text')
    assert_equal 'text \\ text',        output('text \\ text')

    assert_equal 'and <CODE>\\s</CODE> matches space',
                 output('and <tt>\\s</tt> matches space')
    assert_equal 'use <CODE><tt>text</CODE></tt> for code',
                 output('use <tt>\\<tt>text</tt></tt> for code')
    assert_equal 'use <CODE><tt>text</tt></CODE> for code',
                 output('use <tt>\\<tt>text\\</tt></tt> for code')
    assert_equal 'use <tt><tt>text</tt></tt> for code',
                 output('use \\<tt>\\<tt>text</tt></tt> for code')
    assert_equal 'use <tt><CODE>text</CODE></tt> for code',
                 output('use \\<tt><tt>text</tt></tt> for code')
    assert_equal 'use <CODE>+text+</CODE> for code',
                 output('use <tt>\\+text+</tt> for code')
    assert_equal 'use <tt><CODE>text</CODE></tt> for code',
                 output('use \\<tt>+text+</tt> for code')
    assert_equal 'illegal <tag>not</tag> changed',
                 output('illegal <tag>not</tag> changed')
    assert_equal 'unhandled <p>tag</p> unchanged',
                 output('unhandled <p>tag</p> unchanged')
  end

  def output str
    @formatter.convert_flow @am.flow str
  end

end

