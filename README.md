Invoke the Lambda function with this command:

```
aws lambda invoke --function-name block_function out --region eu-central-1 --cli-binary-format raw-in-base64-out --log-type Tail --query 'LogResult' --output text |  base64 -d
```
