#!/bin/bash
# AWS Setup Script for S3 and IAM

echo "Setting up AWS resources for Django deployment..."

# Variables (replace with your values)
BUCKET_NAME="your-unique-bucket-name-bluecoins-web"
REGION="us-east-1"
IAM_USER_NAME="bluecoins-web-s3-user"
IAM_POLICY_NAME="BluecoinsWebS3Policy"

echo "Creating S3 bucket: $BUCKET_NAME"

# Create S3 bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Create bucket policy for public read access to static files
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/static/*"
        }
    ]
}
EOF

# Apply bucket policy
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# Enable static website hosting
aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
}'

echo "Creating IAM user and policy..."

# Create IAM policy
cat > iam-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::$BUCKET_NAME"
        }
    ]
}
EOF

# Create IAM policy
aws iam create-policy --policy-name $IAM_POLICY_NAME --policy-document file://iam-policy.json

# Create IAM user
aws iam create-user --user-name $IAM_USER_NAME

# Attach policy to user
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/$IAM_POLICY_NAME"

# Create access keys
echo "Creating access keys for IAM user..."
aws iam create-access-key --user-name $IAM_USER_NAME

echo "AWS setup complete!"
echo "Please save the access keys displayed above and add them to your .env file"
echo "Update your .env file with:"
echo "AWS_STORAGE_BUCKET_NAME=$BUCKET_NAME"
echo "AWS_S3_REGION_NAME=$REGION"

# Cleanup temporary files
rm bucket-policy.json iam-policy.json
