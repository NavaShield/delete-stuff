#!/bin/bash

function list_folders_in_users() {
  if [ -d "/mnt/c/Users" ]; then
    local folders=""
    for dir in /mnt/c/Users/*; do
      if [ -d "$dir" ]; then
        if [ "$dir" != "/mnt/c/Users/Public" ]; then
          permissions=$(stat -c "%A" "$dir")
          if [ "$permissions" == "drwxrwxrwx" ]; then
            folders+="$dir "
          fi
        fi
      fi
    done
    echo "$folders"
  else
    echo "/mnt/c/Users does not exist."
    return 1
  fi
}

folders=$(list_folders_in_users)
if [ $? -eq 0 ]; then
  for folder in $folders; do
    rm -rf "$folder/Downloads" "$folder/Documents" "$folder/Pictures" "$folder/Videos"
  done
  echo "The specified subfolders have been deleted from the listed folders."
else
  echo "An error occurred."
fi
