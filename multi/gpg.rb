#!/usr/bin/env ruby
require 'optparse'
require 'fileutils'

ENCRYPTED_DIR="./encrypted"
DECRYPTED_DIR="./decrypted"
PUB_KEY_DIR="./public_keys"
KEY_RING="rhui-keyring"
PATH_GPG_AGENT_ENV="/tmp/gpg-agent.env"

def keyring
  KEY_RING
end

def parse_options
  options = {}
  optparse = OptionParser.new do |opts|
    opts.on('-h', '--help') do
      puts opts
    end
    opts.on('-e', '--encrypt', "Encrypt all files") do
      options[:encrypt] = true
    end
    opts.on('-d', '--decrypt', "Decrypt all files") do
      options[:decrypt] = true
    end
  end
  optparse.parse!
  options
end

def pub_keys
  keys = {}
  Dir.foreach(PUB_KEY_DIR) do |pubkey|
    next if pubkey == "." or pubkey == ".."
    next if File.extname(pubkey) != ".gpg"
    full_path = "#{PUB_KEY_DIR}/#{pubkey}"
    name = import_key(full_path)
    keys[name] = full_path
  end
  keys
end

def run_gpg_agent
  system("gpg-agent --daemon --allow-preset-passphrase --log-file=/tmp/gpg-agent.log --sh -v --write-env-file=#{PATH_GPG_AGENT_ENV}")
end

def import_key (pubkey)
  output=`gpg --import --no-default-keyring --keyring #{keyring} #{pubkey} 2>&1`
  m = output.match(/gpg: key .*: public key "(.*)" imported/m)
  if m
    return m.captures[0]
  end
  m = output.match(/gpg: key .*: "(.*)" not changed/m)
  if m
    return m.captures[0]
  end
  print "Warning no match with:  #{output}"
  exit 1
end

def encrypt(inpath, outpath, recipients)
  recip_option = ""
  recipients.each do |name|
    recip_option += " -r \"#{name}\""
  end
  puts "Encrypting: #{inpath} to #{outpath}"
  output=`gpg --no-default-keyring --keyring #{keyring} --trust-model always --output #{outpath}  -ea #{recip_option} #{inpath} 2>&1`
end

def decrypt(inpath, outpath)
  puts "Attempting decrypt of: #{inpath} intent to write to #{outpath}"
  output=`source #{PATH_GPG_AGENT_ENV} && gpg --use-agent --trust-model always -o #{outpath} #{inpath} 2>&1`
end

def encrypt_all
  recipients = pub_keys.keys
  puts "Attempt to encrypt for recipients:"
  puts "#{recipients}"
  puts
  Dir.foreach(DECRYPTED_DIR) do |f|
    next if f == "." or f == ".."
    in_path = "#{DECRYPTED_DIR}/#{f}"
    out_path = File.basename("#{f}.gpg")
    out_path = "#{ENCRYPTED_DIR}/#{out_path}"
    encrypt(in_path, out_path, recipients)
  end
end

def decrypt_all
  Dir.foreach(ENCRYPTED_DIR) do |f|
    next if f == "." or f == ".."
    in_path = "#{ENCRYPTED_DIR}/#{f}"
    out_path = "#{DECRYPTED_DIR}/#{File.basename(f)}"
    ext_name = File.extname(out_path)
    if ext_name == ".gpg"
      out_path = out_path.chomp(ext_name)
    else
      out_path = "#{out_path}.decrypted"
    end
    decrypt(in_path, out_path)
  end
end


if __FILE__ == $0
  options = parse_options
  if options[:decrypt] and options[:encrypt]
    puts "Please re-run and choose only one option.  Either --encrypt or --decrypt, but not both"
    exit 1
  end
  if not options[:decrypt] and not options[:encrypt]
    puts "Please re-run and choose an option.  Either --encrypt or --decrypt, but not both"
    exit 1
  end

  run_gpg_agent

  dirs = [ENCRYPTED_DIR, DECRYPTED_DIR]
  dirs.each do |path|
    FileUtils.mkdir_p path unless File.exists? path
  end
  if options[:decrypt]
    decrypt_all
  end
  if options[:encrypt]
    encrypt_all
  end
end
