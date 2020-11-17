# acquia-db-dump-s3-sync-action

GitHub Action to download database dumps from Acquia and copy them to S3.

## Usage

```yaml
- uses: chromatichq/acquia-backup-sync-action@v1
  with:
    acquia_project: 'example-project'  # required.
    aws_s3_bucket: 'bucket-name'  # required.
  env:
    ACQUIA_PRIVATE_KEY: ${{ secrets.ACQUIA_PRIVATE_KEY }}  # required.
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}  # required.
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}  # required.
    AWS_DEFAULT_REGION: 'us-west-2' # required.
```
