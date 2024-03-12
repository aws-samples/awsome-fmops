cd infra

DOTENV="../.env"
# https://stackoverflow.com/a/13659345
# https://superuser.com/questions/284187/bash-iterating-over-lines-in-a-variable
echo "" > ${DOTENV}
terraform output | while read line; do
  echo "export ${line//[[:blank:]]/}"  >> ${DOTENV}
done