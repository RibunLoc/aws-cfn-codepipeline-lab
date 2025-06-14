#!/bin/bash
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Xóa stack chính
echo "Đang xóa stack chính..."
aws cloudformation delete-stack --stack-name "$MAIN_STACK_NAME" --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name "$MAIN_STACK_NAME" --region "$REGION"

if [ $? -eq 0 ]; then
    echo "Đã xóa stack "$MAIN_STACK_NAME" thành công."
else
    echo "Lỗi khi xóa stack "$MAIN_STACK_NAME"."
    exit 1
fi


# Xóa bucket S3
echo "Đang xóa bucket S3..."
aws s3 rm "s3://$BUCKET_NAME" --recursive --region "$REGION"
if [ $? -eq 0 ]; then
    echo "Bcuket đã được empty thành công."
else
    echo "Không thể emty được bucket."
    exit 1
fi

aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"

if [ $? -eq 0 ]; then
    echo "Đã xóa bucket "$BUCKET_NAME" thành công."
else
    echo "Lỗi khi xóa bucket "$BUCKET_NAME"."
    exit 1
fi