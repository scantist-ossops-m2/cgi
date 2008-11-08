require 'test/unit'
require 'cgi'
require 'cgi/session'
require 'stringio'

class CGISessionTest < Test::Unit::TestCase


  def setup
    FileUtils.rm(Dir::glob(File.dirname(__FILE__)+"/session_dir/*"))
  end


  def teardown
    @environ.each do |key, val| ENV.delete(key) end
    $stdout = STDOUT
   FileUtils.rm(Dir::glob(File.dirname(__FILE__)+"/session_dir/*"))
  end

  def test_cgi_session_core
    @environ = {
      'REQUEST_METHOD'  => 'GET',
  #    'QUERY_STRING'    => 'id=123&id=456&id=&str=%40h+%3D%7E+%2F%5E%24%2F',
  #    'HTTP_COOKIE'     => '_session_id=12345; name1=val1&val2;',
      'SERVER_SOFTWARE' => 'Apache 2.2.0',
      'SERVER_PROTOCOL' => 'HTTP/1.1',
    }
    ENV.update(@environ)
    cgi = CGI.new
    session = CGI::Session.new(cgi,"tmpdir"=>File.dirname(__FILE__)+"/session_dir")
    session["key1"]="value1"
    session["key2"]="\x8F\xBC\x8D]".force_encoding("SJIS")
    assert_equal("value1",session["key1"])
    assert_equal("\x8F\xBC\x8D]".force_encoding("SJIS"),session["key2"])
    session.close
    $stdout = StringIO.new
    cgi.out{""}

    @environ = {
      'REQUEST_METHOD'  => 'GET',
      # 'HTTP_COOKIE'     => "_session_id=#{session_id}",
      'QUERY_STRING'    => "_session_id=#{session.session_id}",
      'SERVER_SOFTWARE' => 'Apache 2.2.0',
      'SERVER_PROTOCOL' => 'HTTP/1.1',
    }
    ENV.update(@environ)
    cgi = CGI.new
    session = CGI::Session.new(cgi,"tmpdir"=>File.dirname(__FILE__)+"/session_dir")
    $stdout = StringIO.new
    assert_equal("value1",session["key1"])
    assert_equal("\x8F\xBC\x8D]".force_encoding("SJIS"),session["key2"])
    session.close

  end
end
