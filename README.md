<p align="center">
 <img width="100px" src="images/azure-database-postgresql-server.svg" align="center" alt="Azure Database for PostgreSQL" />
 <h2 align="center">Azure Database for PostgreSQL (PSQL)</h2>
 <p align="center">The repository is designed to store and organize scripts, and other resources used for working with Azure Database for PostgreSQL!</p>
</p>

## Prerequisites

- [A valid Azure account][azure-account]
- [Azure CLI][azure-cli]

## File Descriptions

- **[create-psql-flex]**: The bicep folder creates an Azure Database for PostgreSQL with data encryption and enables both PostgreSQL and Azure Active Directory authentication.

## Usage
Each file in this folder is designed to perform a specific task with AGW or provide troubleshooting information. Before running a file or using any of the provided information, make sure to replace any placeholders enclosed within ```'<>'``` with your own information and follow the instructions carefully.

## Disclaimer
Please note that this is provided as-is and may not suit all use cases. Use at your own discretion and make sure to thoroughly test before deployment in a production environment.

[azure-account]: https://azure.microsoft.com/en-us/free
[azure-cli]: https://docs.microsoft.com/en-us/cli/azure
[create-psql-flex]:create-psql-flex
