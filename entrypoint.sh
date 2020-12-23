#!/bin/bash -l

php --version
aws --version

# Set the ssh key name.
SSH_KEY_NAME="acquia"

# Configure the known hosts.
ssh-keyscan -t rsa "$INPUT_ACQUIA_PROJECT.ssh.prod.acquia-sites.com" >> ~/.ssh/known_hosts

# Get a list of available Acquia databases.
ACQUIA_DATABASES=$(ssh -i ~/.ssh/"$SSH_KEY_NAME" "$INPUT_ACQUIA_PROJECT"."$INPUT_ACQUIA_ENVIRONMENT"@"$INPUT_ACQUIA_PROJECT".ssh.prod.acquia-sites.com ls /mnt/files/"$INPUT_ACQUIA_PROJECT"/backups/)
echo ""
echo "Acquia Databases:"
echo "$ACQUIA_DATABASES"

# Get a list of databases already synced to S3.
S3_DATABASES=$(aws s3 ls s3://"$INPUT_AWS_S3_BUCKET" | awk '{print $4}')
echo ""
echo "S3 Databases:"
echo "$S3_DATABASES"

# Build a list of files in Acquia, but not in S3 that should be copied over.
FILE_DIFF=$(comm -23 <(echo "$ACQUIA_DATABASES" | sort) <(echo "$S3_DATABASES" | sort) | grep -v on-demand)
echo ""
echo "Files to Upload:"
echo "$FILE_DIFF"

# Loop through the new files and download them from Acquia, then upload to S3.
while IFS=$'\n' read -ra DATABASE_FILE_NAME; do
  echo ""
  echo "Downloading $DATABASE_FILE_NAME from Acquia."
  scp -i ~/.ssh/"$SSH_KEY_NAME" "$INPUT_ACQUIA_PROJECT"."$INPUT_ACQUIA_ENVIRONMENT"@"$INPUT_ACQUIA_PROJECT".ssh.prod.acquia-sites.com:/mnt/files/"$INPUT_ACQUIA_PROJECT"/backups/"$DATABASE_FILE_NAME" ./
  echo "Uploading $DATABASE_FILE_NAME to the $INPUT_AWS_S3_BUCKET S3 bucket."
  aws s3 cp "$DATABASE_FILE_NAME" "s3://$INPUT_AWS_S3_BUCKET"
  rm "$DATABASE_FILE_NAME"
done <<< "$FILE_DIFF"
