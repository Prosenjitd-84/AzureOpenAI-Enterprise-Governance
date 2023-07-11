# Azure-OpenAI-Enterprise-Governance

This repository helps in exposing Azure OpenAI through an enterprise governance structure implemented using Azure API Management. The APIM policies are an accelerator towards the following deployment architecture - 

<img width="730" alt="image" src="https://github.com/Prosenjitd-84/Azure-OpenAI-Enterprise-Governance/assets/67834586/b788877a-72ff-4367-98ca-27866da37b03">



To run the Terraform modules, here are the steps - 

1. source "--any location of your choice--/.bashrc"
2. terraform init -backend-config=backend.conf
3. terraform plan -out tfplan
4. Terraform apply tfplan

You can use an azure Blob Storage for storing TF state...here is the content of the env source file not stored in the repo for security reasons

export TF_VAR_ARM_SUBSCRIPTION_ID="XXX"

export TF_VAR_ARM_TENANT_ID="XXX"

export TF_VAR_ARM_CLIENT_ID="XXX"

export TF_VAR_ARM_CLIENT_SECRET="XXX"

export TF_VAR_State_STORAGE_ACCESS_KEY="XXX"
