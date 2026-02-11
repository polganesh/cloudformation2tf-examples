# cloudformation2tf-examples

How to install 

`brew install cf2tf`

Get Cloudformation stack

`aws cloudformation get-template --stack-name YourStackName`

or to get it in file 

`aws cloudformation get-template \
    --stack-name YourStackName \
    --query 'TemplateBody' \
    --output text > template.yaml`

How to run

`cf2tf <cloudformation-yaml-file.yaml>
`
or 
`cf2tf stack.yaml -o my-tf-code
`
This will create terraform code in **my-tf-code**