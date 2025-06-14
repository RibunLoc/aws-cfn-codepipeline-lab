#!/bin/bash
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Tạo bucket S3 nếu chưa tồn tại
echo "Đang tạo bucket S3..."
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" || echo "Bucket đã tồn tại, bỏ qua bước tạo bucket."


S3_BASE_URL="https://$BUCKET_NAME.s3.$REGION.amazonaws.com"

# Upload từng module và main stack lên S3
echo "Đang upload module stack lên S3..."
aws s3 cp "../$MODULE_DIR" "s3://$BUCKET_NAME/$MODULE_DIR" --region $REGION --recursive
echo "Đã upload module stack lên S3 thành công."

# Upload main stack lên S3
echo "Đang upload main stack lên S3..."
aws s3 cp "../$TEMPLATE_FILE" "s3://$BUCKET_NAME/$TEMPLATE_FILE" --region $REGION
echo "Đã upload main stack lên S3 thành công."

echo "Upload thành công tất cả các stack lên S3."

# Bắt đầu triển khai stack main

echo "Đang triển khai stack chính..."
aws cloudformation create-stack --stack-name "$MAIN_STACK_NAME" --template-url "$S3_BASE_URL/$TEMPLATE_FILE" --capabilities CAPABILITY_NAMED_IAM --region "$REGION" --parameters ParameterKey=BucketName,ParameterValue=$BUCKET_NAME


echo "chờ stack chính được triển khai..."

aws cloudformation wait stack-create-complete --stack-name $MAIN_STACK_NAME

if [ $? -eq 0 ]; then
  echo "Triển khai thành công!"
  echo "stack output: "
  aws cloudformation describe-stacks --stack-name $MAIN_STACK_NAME --query "Stacks[0].Outputs" --output table
else 
  echo "Triển khai thất bại! Hãy kiểm tra lại."
fi


    


