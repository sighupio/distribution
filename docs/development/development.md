# Development FAQ

## **What are the points of the library used by furyctl that are not automatically generated and what's their purpose?**

<details>
  <summary>Answer</summary>

The files used by `furyctl`, in addition to the schema generated in `pkg/apis`, are:

- **Defaults for the distribution**: These are contained in the `defaults` folder. These files define the default values and settings that are used for the configuration, ensuring that the distribution behaves in a predictable manner when no explicit configurations are provided.

- **Templates for the distribution**: These are found in the `templates` folder and include specific templates like Terraform for `EKSCluster`. These templates serve as blueprints for configuring and deploying components (like cloud resources), enabling customizations for different environments.

- **Rules for `furyctl.yaml` changes**: The rules determine which changes are permitted in the `furyctl.yaml` file after initial deployment. These rules are critical for ensuring that modifications to the configuration are safe and consistent with the intended deployment workflow, particularly when managing state changes across environments.

- **Basic models for SD and `furyctl.yaml` kind and version**: These are contained in the `pkg/apis/config` folder. These Go structures are used to parse the `kfd.yaml` file and the initial information such as `Kind` and `APIVersion` from the `furyctl.yaml`.
</details>

---

## **How do the rules for immutable fields/migrations work and where are they evaluated in furyctl's code?**

<details>
  <summary>Answer</summary>

Once you install fury for the first time, if you change mind about a configuration and you want to edit the `furyctl.yaml` file and reinstall there are some rules in place. These rules can contain migration paths and immutable fields.

The rules for immutable fields and migrations are evaluated within the core logic of the `furyctl` tool. These rules are defined in the configuration files and enforced by the tool to ensure consistency and prevent misconfigurations.

These rules serve as safety mechanisms during module changes (e.g., switching from the Loki logging system to OpenSearch). Some changes are allowed, while others are not. For example, fields marked as `immutable` will return an error if an attempt is made to change them.

The rules are configured in the `rules` folder, and the commands/scripts executed for each rule are found in `templates/distribution/scripts/pre-apply.sh.tpl`.

Additionally, **Reducers** are special fields rendered inside the template engine that indicate whether a particular feature or module of the distribution has changed. The `.to` and `.from` strings indicate these changes precisely.

For example from logging `loki` to `opensearch` the `.form` key contains the previous value `loki` and the key `.to` contains `opensearch` so you can run the `deleteLoki` script by checking the `.from` key. The new module `opensearch` will then be installed by the standard apply flow. (`templates/distribution/scripts/pre-apply.sh.tpl:106`)

</details>

---

## **What's the dependency evaluation flow in the `kfd.yaml` and how does furyctl download them?**

<details>
  <summary>Answer</summary>

The `kfd.yaml` file, specific to the distribution downloaded by `furyctl`, contains the definitions of dependencies that the distribution relies on.

Furyctl reads the version information embedded within the `kfd.yaml` file to determine which dependencies need to be fetched. These dependencies are typically other resources or libraries required for the successful deployment or operation of the current distribution.

Once identified, `furyctl` downloads or references these dependencies from either a local or remote repository. This ensures that the distribution is fully equipped with all the necessary components for deployment, preventing version mismatches and compatibility issues. The process ensures the environment is set up with the correct versions and configurations.

</details>

---

## **What's inside the Makefile?**

<details>
  <summary>Answer</summary>

The important commands in the `Makefile` are:

- **`make tools-go`**: This command it's important and installs all the tools required for the subsequent commands.

- **`make generate-go-models`**: This command generates Go code from the JSON schema files. The generated code defines the data models used in the codebase, providing a structured representation of the resources and configurations used by `furyctl`. It essentially converts the schema into Go structs, which are essential for interacting with the configuration data programmatically. The tool used to generate the code is https://github.com/sighupio/go-jsonschema.

- **`make generate-docs`**: This command generates Markdown documentation from the schema files. It extracts the necessary information from the schemas and formats it into human-readable documentation, helping developers and users understand how to configure and use the distribution and resources. This documentation serves as the primary reference for anyone interacting with `furyctl`.

To have a working dev environment you need to launch `make tools-go` and you must have `asdf` installed and configured.

</details>

---

## **What's the purpose of a private schema, and what are the differences from the public schema?**

<details>
  <summary>Answer</summary>

The `public` schema serves as the base schema, which is shared and visible to all users. It defines the core structure and expected properties for a particular resource or configuration.

The `private` schema is a modified version of the public schema, typically used internally within `furyctl`. It includes additional fields or configurations that should not be exposed in the public configuration files (like `furyctl.yaml`), but are still necessary for certain internal operations or customizations within the codebase.

A notable case where the private schema is used is with the `EKSCluster` resource. Here, a patch (`schemas/private/ekscluster-kfd-v1alpha2.patch.json`) is applied to the public schema (`schemas/public/ekscluster-kfd-v1alpha2.json`) with `json-patch` and `jq` to add internal fields that are required for `furyctl` to function but are not intended for end-user modification. This separation ensures that sensitive or internal details remain private while maintaining flexibility for internal customization. Note that this process is automatic and managed by the `make generate-go-models` command. To configure a new private schema / patch create a new configuration on the Makefile (example on line 72) and a patch like `schemas/private/ekscluster-kfd-v1alpha2.patch.json` that is a standard json patch (https://jsonpatch.com).

</details>
