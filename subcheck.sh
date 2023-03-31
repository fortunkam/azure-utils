echo "Subscription Check"

spName="sbcheck-sp"
rgName="sbcheck-rg"

echo "Create a Service Principal"
az ad sp create-for-rbac -n $spName
sp_id=$(az ad sp list --display-name $spName --query [0].id --output tsv)

echo "create a resource group"
rg_id=$(az group create -n $rgName --location "uksouth" --query id --output tsv)

echo "Create a role assignment (Reader)"
az role assignment create --assignee $sp_id --role "Reader" --resource-group $rgName

echo "Create a role assignment (Contributor)"
az role assignment create --assignee $sp_id --role "Contributor" --resource-group $rgName

echo "Create a role definition"
az role definition create --role-definition "{
    \"Name\": \"Sub Check Sample Role Definition\",
    \"Description\": \"Sample Role defintion to check creation rights.\",
    \"Actions\": [
        \"Microsoft.Support/*\"
    ],
    \"DataActions\": [
    ],
    \"NotDataActions\": [
    ],
    \"AssignableScopes\": [\"$rg_id\"]
}"

echo "Create a role assignment (Sub Check Sample Role Definition)"
az role assignment create --assignee $sp_id --role "Sub Check Sample Role Definition" --resource-group $rgName

echo "List the assigned policies"
az policy assignment list > policies.json

echo "Removing Role assignment (Sub Check Sample Role Definition)"
az role assignment delete --assignee $sp_id --role "Sub Check Sample Role Definition"

echo "Removing Service Principal"
az ad sp delete --id $sp_id

echo "Removing Role Definition"
az role definition delete --name "Sub Check Sample Role Definition"

echo "Removing Resource Group"
az group delete -n $rgName -y
