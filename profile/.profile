# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true

# Shortcuts for General Management
alias e="exit"
alias cm="ps -eo comm,pcpu --sort -pcpu | head -8; ps -eo comm,pmem --sort -pmem | head -8"
alias st='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'
alias myip='curl icanhazip.com'
alias wttr='curl wttr.in'

neofetch

# Version of the node binary to use
VERSION="1.4.20"

# Get system information
ARCH=$(uname -m)
OS=$(uname -s)

# Determine the node binary name based on the architecture and OS
if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-amd64"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-amd64"
    fi
elif [ "$ARCH" = "aarch64" ]; then
    if [ "$OS" = "Linux" ]; then
        NODE_BINARY="node-$VERSION-linux-arm64"
    elif [ "$OS" = "Darwin" ]; then
        NODE_BINARY="node-$VERSION-darwin-arm64"
    fi
fi


# Shortcuts for Service
alias peer-count='cd ~/ceremonyclient/node && grpcurl -plaintext -max-msg-sz 150000000 localhost:8337 quilibrium.node.node.pb.NodeService.GetPeerManifests | grep peerId | wc -l && cd ~'
node-info() {
    cd ~/ceremonyclient/node && ./${NODE_BINARY} -node-info && cd ~
}
db-console() {
    cd ~/ceremonyclient/node && ./${NODE_BINARY} --db-console && cd ~
}

balance() {
    cd ~/ceremonyclient/node && ./${NODE_BINARY} -balance && cd ~
}
alias nlog='sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat'
alias nstart='service ceremonyclient start'
alias nrestart='service ceremonyclient restart'
alias nstop='service ceremonyclient stop'
alias benchmark='increment=$(journalctl -u ceremonyclient -ocat -n 100 | grep increment | awk -F'\[:,\}\]' '\''{for(i=1;i<=NF;i++){if($i~"increment"){gsub(/[ "]/,"",$i); print $(i+1)}}}'\'' | tail -n 1) && difficulty=$(expr 200000 - $increment / 4) && cpus=$(nproc) && score=$(echo "scale=2; ($cpus*$cpus*1000)/$difficulty" | bc) && echo "" && echo "CPU(s): $cpus" && echo "Increment: $increment" && echo "Difficulty: $difficulty" && echo "Score: $score"'