# Langtrace Azure Setup

This repo serves as an IaC for setting up [Langtrace](https://langtrace.ai) on Azure.

## Requirements

- Azure Account
- Clickhouse server (Cloud or Self-Hosted)
- Setup **azd** by following the instructions [here](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

## Run the setup

```bash
azd up
```

> [!NOTE]
> You will be asked to input variables for the setup. Make sure the variable `langtrace_project` is unique as it will be used to name the resources.

To customize the setup, modify the variables in [`variables.tf`](./infra/variables.tf) and [`main.tfvars.json`](./infra/main.tfvars.json).

> [!WARNING]
> The terraform state is stored in path `./.azure/langtrace-azure/infra/terraform.tfstate`. Make sure to store it securely.

## Destroy the setup

```bash
azd down
```

If you are asked to input variables, enter any random values to proceed with the delete process.
