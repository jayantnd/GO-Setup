#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
   echo "You don't have sufficient privileges to run this script. Please run with [sudo]" 1>&2
   exit 1
fi

print_help() {
    echo "Usage: bash goinstall.sh OPTION"
    echo -e "\nOPTIONS:"
    echo -e "  --install\tTo install at /usr/local/go/"
    echo -e "  --remove\tTo remove current installed version"
}

which_version() {
    echo "Please enter Go Version you want to install:"
    read VERSION
    DFILE="go$VERSION.darwin-amd64.tar.gz"
}

if [ "$1" == "--install" ]; then
    which_version
elif [ "$1" = "--remove" ]; then
    rm -rf "/usr/local/go/"
    sed -i '' '/# GOSetup/d' "$HOME/.bash_profile"
    sed -i '' '/export GOROOT/d' "$HOME/.bash_profile"
    sed -i '' '/:$GOROOT/d' "$HOME/.bash_profile"
    sed -i '' '/export GOPATH/d' "$HOME/.bash_profile"
    sed -i '' '/:$GOPATH/d' "$HOME/.bash_profile"
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
sudo curl -o /tmp/$DFILE https://storage.googleapis.com/golang/$DFILE
if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Extracting ..."
tar -C "/tmp/" -xzf /tmp/$DFILE
mv "/tmp/go" "/usr/local/go"
chown -R $(logname) "/usr/local/go"
rm -f /tmp/$DFILE

touch "$HOME/.bash_profile"
{
    echo '# GOSetup'
    echo 'export GOROOT=/usr/local/go'
    echo 'export PATH=$PATH:$GOROOT/bin'
    echo 'export GOPATH=$HOME/Workspace/Go'
    echo 'export PATH=$PATH:$GOPATH/bin'
} >> "$HOME/.bash_profile"

mkdir -p $HOME/Workspace/Go/{src,pkg,bin}
chown -R $(logname) $HOME/Workspace

echo -e "\nGo $VERSION is installed successfully.\nMake sure to relogin into your shell or run:"
echo -e "\n\tsource $HOME/.bash_profile\n\n to update your environment variables."
echo "Tip: Opening a new terminal window usually just works. :)"
