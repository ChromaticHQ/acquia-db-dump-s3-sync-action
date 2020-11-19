
#!/bin/bash -l

php --version
aws --version

# Set the ssh key name.
SSH_KEY_NAME="id_rsa"

# Get a list of available Acquia databases.
ACQUIA_DATABASES=$(ssh -i ~/.ssh/"$SSH_KEY_NAME" "$INPUT_ACQUIA_PROJECT"."$INPUT_ACQUIA_ENVIRONMENT"@"$INPUT_ACQUIA_PROJECT".ssh.prod.acquia-sites.com ls /mnt/files/"$INPUT_ACQUIA_PROJECT"/backups/)
# Get a list of databases already synced to S3.
S3_DATABASES=$(aws s3 ls s3://"$INPUT_AWS_S3_BUCKET" | awk '{print $4}')

# Build a list of files in Acquia, but not in S3 that should be copied over.
FILE_DIFF=$(diff <(echo "$ACQUIA_DATABASES") <(echo "$S3_DATABASES") --suppress-common-lines | grep "$ACQUIA_DATABASES" | grep '<' | grep -vE 'on-demand' | awk '{print $2}')

echo ""
echo 'Acquia Databases:'
echo "$ACQUIA_DATABASES"

echo ""
echo 'S3 Databases:'
echo "$S3_DATABASES"

echo ""
echo "Files to Upload:"
echo "$FILE_DIFF"

# Loop through the new files and download them from Acquia, then upload to S3.
while IFS=$'\n' read -ra DATABASE_FILE_NAME; do
  echo ""
  echo "Downloading $DATABASE_FILE_NAME from Acquia."
  # scp -i ~/.ssh/"$SSH_KEY_NAME" "$INPUT_ACQUIA_PROJECT"."$INPUT_ACQUIA_ENVIRONMENT"@"$INPUT_ACQUIA_PROJECT".ssh.prod.acquia-sites.com:/mnt/files/"$INPUT_ACQUIA_PROJECT"/backups/"$DATABASE_FILE_NAME" ./
  echo "Uploading $DATABASE_FILE_NAME to the $INPUT_AWS_S3_BUCKET S3 bucket."
  # aws s3 cp "$DATABASE_FILE_NAME" "s3://$INPUT_AWS_S3_BUCKET"
  # rm "$DATABASE_FILE_NAME"
done <<< "$FILE_DIFF"
