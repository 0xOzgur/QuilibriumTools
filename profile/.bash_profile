# .bash_profile

# If .bash_profile exists, bash doesn't read .profile
if [[ -f ~/.profile ]]; then
  . ~/.profile
fi

# If the shell is interactive and .bashrc exists, get the aliases and functions
if [[ $- == *i* && -f ~/.bashrc ]]; then
    . ~/.bashrc
fi

export HISTTIMEFORMAT="%d/%m/%y %T "


alias e="exit"
alias cm="ps -eo comm,pcpu --sort -pcpu | head -8; ps -eo comm,pmem --sort -pmem | head -8"
alias st='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'
alias myip='curl icanhazip.com'
alias wttr='curl wttr.in'

neofetch


alias peer-count='cd ~/ceremonyclient/node && grpcurl -plaintext -max-msg-sz 150000000 localhost:8337 quilibrium.node.node.pb.NodeService.GetPeerInfo | grep peerId | wc -l && cd ~'
alias node-info='cd ~/ceremonyclient/node && ./node-1.4.18-linux-amd64 -node-info && cd ~'
alias db-console='cd ~/ceremonyclient/node && ./node-1.4.18-linux-amd64 --db-console && cd ~'
alias balance='cd ~/ceremonyclient/node && ./node-1.4.18-linux-amd64 -balance && cd ~'
alias nlog='sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat'
alias nstart='service ceremonyclient start'
alias nrestart='service ceremonyclient restart'
alias nstop='service ceremonyclient stop'