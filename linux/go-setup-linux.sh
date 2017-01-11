#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
   echo "You don't have sufficient privileges to run this script. Please run with [sudo]" 1>&2
   exit 1
fi

print_help() {
    echo "Usage: bash go-setup-linux.sh OPTION"
    echo -e "\nOPTIONS:"
    echo -e "  --32\t\tInstall 32-bit version"
    echo -e "  --64\t\tInstall 64-bit version"
    echo -e "  --remove\tTo remove current installed version"
}

which_version() {
    echo "Please enter Go Version you want to install:"
    read VERSION
    if [ "$1" = "--32" ]; then
    	DFILE="go$VERSION.linux-386.tar.gz"
    elif [ "$1" = "--64" ]; then
    	DFILE="go$VERSION.linux-amd64.tar.gz"
    fi
}

if [ "$1" = "--32" ] || [ "$1" = "--64" ]; then
    which_version $1
elif [ "$1" = "--remove" ]; then
    rm -rf "/usr/local/go/"
    sed -i '/# GoLang/d' "$HOME/.bashrc"
    sed -i '/export GOROOT/d' "$HOME/.bashrc"
    sed -i '/:$GOROOT/d' "$HOME/.bashrc"
    sed -i '/export GOPATH/d' "$HOME/.bashrc"
    sed -i '/:$GOPATH/d' "$HOME/.bashrc"
    echo "Go successfully removed from you system!"
    exit 1
elif [ "$1" = "--help" ]; then
    print_help
    exit 1
else
    print_help
    exit 1
fi

if [ -d "/usr/local/go" ]; then
    echo "Installation directory already exist. Exiting."
    exit 1
fi

echo "Downloading https://storage.googleapis.com/golang/$DFILE ..."
wget https://storage.googleapis.com/golang/$DFILE -O /tmp/$DFILE
if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi
echo "Extracting ..."
tar -C "/tmp/" -xzf /tmp/$DFILE
mv "/tmp/go" "/usr/local/go"
chown -R $SUDO_USER:$SUDO_USER "/usr/local/go"
rm -f /tmp/$DFILE

touch "$HOME/.bashrc"
{
    echo '# GoLang'
    echo 'export GOROOT=/usr/local/go'
    echo 'export PATH=$PATH:$GOROOT/bin'
    echo 'export GOPATH=$HOME/Work/GoLang'
    echo 'export PATH=$PATH:$GOPATH/bin'
} >> "$HOME/.bashrc"

mkdir -p $HOME/Work/GoLang/src
mkdir -p $HOME/Work/GoLang/pkg
mkdir -p $HOME/Work/GoLang/bin
chown -R $SUDO_USER:$SUDO_USER $HOME/Work

echo -e "\nGo $VERSION is installed successfully.\nMake sure to relogin into your shell or run:"
echo -e "\n\tsource $HOME/.bashrc\n\n to update your environment variables."
echo "Tip: Opening a new terminal window usually just works. :)"
