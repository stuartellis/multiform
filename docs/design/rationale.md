# Why?

- We want to define all of the aspects of the infrastructure for a project with Terraform. This may include configurations in multiple cloud services, such as AWS and Datadog.
- It is more effective to maintain all of the components of a service in one repository. A service is likely to have at least three infrastructure components, and may also have custom application code.
- We want to make changes quickly, frequently and safely. This requires that we minimise the size of the Terraform state that is used for each operation.
- We want to manage the Terraform states for all of the components of a project in a consistent way. This enables us to develop and apply tooling, such as automated refactoring, backups, removal of obsolete state files, and reporting.
- We want to be able to deploy, update and destroy instances of an infrastructure component without changing the state of other components. For example, we want to release updates to an application without changing storage or monitoring components.
- We may want to deploy some components for a limited time or a specific purpose. For example, we may want to delete test instances of application components on a schedule, or when they are no longer needed, or have instructure components that are only deployed to run performance tests.
- We may want to be able to manage multiple instances of an infrastructure component in the same cloud account without deploying all of the components. For example, we may want to deploy separate copies of components to develop multiple features in parallel, or as part of a process for recovering data.
- We want to avoid adopting third-party tools for operating Terraform. These introduce extra effort to learn and manage. More importantly, some of these tools are difficult to migrate away from, because they require that you write your Terraform code in specific ways.
- We want to avoid anything that limits how developers orchestrate deployments. This tooling supports the deployment of a defined piece of infrastructure with Terraform. It can be used in multiple stages of a deployment process, and mixed with other tools.
