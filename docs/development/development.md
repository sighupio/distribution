# Development FAQ

> **Note:** this repository is **data-only**. It no longer contains Go code, a
> `go.mod`, or code-generated config types. The Go structs that `furyctl` uses
> to read a `furyctl.yaml` are now **hand-maintained inside furyctl**
> (`internal/apis/kfd/v1alpha2/<provider>/...` and `internal/apis/config`). See
> furyctl's `internal/apis/kfd/v1alpha2/README.md` for where to act when a field
> furyctl reads changes. The JSON **public** schemas here remain the source of
> truth for runtime validation.

## **What does this repository provide to furyctl?**

<details>
  <summary>Answer</summary>

- **Public JSON schemas** (`schemas/public`): the source of truth used by
  `furyctl` to validate `furyctl.yaml` at runtime, and the reference for the
  hand-maintained Go structs in furyctl. (There is no longer a `private` schema
  — see below.)

- **Defaults** (`defaults` folder): default values and settings applied when no
  explicit configuration is provided, so the distribution behaves predictably.

- **Templates** (`templates` folder): blueprints (e.g. Terraform for
  `EKSCluster`) used to configure and deploy components across environments.

- **Rules for `furyctl.yaml` changes** (`rules` folder): which changes are
  permitted after the initial deployment (immutable fields, migration paths).

- **`kfd.yaml`**: the distribution manifest (versions, modules, tools,
  dependencies) that furyctl reads.

There is **no Go code** here anymore. In particular, `pkg/apis` (the
code-generated config types and the hand-written `config` models) has been moved
into furyctl.
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

## **What's inside the mise.toml?**

<details>
  <summary>Answer</summary>

The important mise task is:

- **`mise run generate-docs`**: generates Markdown documentation from the JSON
  schema files, the primary reference for configuring the distribution.

There is no longer a Go code-generation task: the config types are hand-written
in furyctl and this repository ships only data.

To have a working dev environment you need to launch `mise install`. The required tool versions are managed in `mise.toml`.

</details>

---

## **What happened to the private schema and the generated Go library?**

<details>
  <summary>Answer</summary>

They were removed. Previously, the config Go types were code-generated from the
JSON schemas with `go-jsonschema`, and the `EKSCluster` resource had a `private`
schema (a JSON patch over the public one) that added internal-only fields.

That whole pipeline is gone:

- furyctl no longer depends on this repository as a Go module; it hand-maintains
  curated structs that model only the fields it reads.
- The fields that the old `private` schema added (IAM role ARNs, VPC id, …) were
  never user input — furyctl computes them from infrastructure (Terraform /
  OpenTofu) outputs and injects them at runtime. They now live as
  furyctl-owned fields in furyctl's `ekscluster/private` package.
- Runtime validation of `furyctl.yaml` uses the **public** schema only (it
  already did); the private schema was only ever consumed by code generation.

To change a field furyctl reads, edit the curated struct in furyctl (see
furyctl's `internal/apis/kfd/v1alpha2/README.md`) and, if it is a user-facing
field, the corresponding **public** JSON schema here.

</details>
