#!/usr/bin/env ruby

TEST_FILE="this_is_a_test.gpg"
PATH_GPG_AGENT_ENV="/tmp/gpg-agent.env"

def run_gpg_agent
  system("gpg-agent --daemon --allow-preset-passphrase --log-file=/tmp/gpg-agent.log --sh -v --write-env-file=#{PATH_GPG_AGENT_ENV}")
end

def decrypt
  outfile = TEST_FILE.chomp(".gpg")
  system("source #{PATH_GPG_AGENT_ENV} && gpg --use-agent -o #{outfile} #{TEST_FILE}")
end

if __FILE__ == $0
  run_gpg_agent
  decrypt
end

