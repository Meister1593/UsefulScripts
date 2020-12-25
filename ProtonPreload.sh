if [[ -d "/home/$USER/.steam/steam/steamapps/common/"$1"/dist" ]]; then
    export W="/home/$USER/.steam/steam/steamapps/common/"$1"/dist"
elif [[ -d "/home/$USER/.steam/steam/compatibilitytools.d/"$1"/dist" ]]; then
    export W="/home/$USER/.steam/steam/compatibilitytools.d/"$1"/dist"
else
    echo "Proton not found, exiting."
    exit 1
fi
export WINEVERPATH=$W
export PATH=$W/bin:$PATH
export WINESERVER=$W/bin/wineserver
export WINELOADER=$W/bin/wine
export WINEDLLPATH=$W/lib/wine/fakedlls
export LD_LIBRARY_PATH="$W/lib:$LD_LIBRARY_PATH"
echo "Proton to wine paths applied successfully."
