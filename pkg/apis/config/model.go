// Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package config

type Furyctl struct {
	APIVersion string      `yaml:"apiVersion" validate:"required,api-version"`
	Kind       string      `yaml:"kind"       validate:"required,cluster-kind"`
	Metadata   FuryctlMeta `yaml:"metadata"   validate:"required"`
	Spec       FuryctlSpec `yaml:"spec"       validate:"required"`
}

type FuryctlSpec struct {
	DistributionVersion string `yaml:"distributionVersion" validate:"required"`
}

type FuryctlMeta struct {
	Name string `yaml:"name" validate:"required"`
}

type KFD struct {
	Version        string        `yaml:"version"        validate:"required,permissive-semver"`
	Modules        KFDModules    `yaml:"modules"        validate:"required"`
	Kubernetes     KFDKubernetes `yaml:"kubernetes"     validate:"required"`
	FuryctlSchemas KFDSchemas    `yaml:"furyctlSchemas" validate:"required"`
	Tools          KFDTools      `yaml:"tools"          validate:"required"`
}

type KFDModules struct {
	Auth       string `yaml:"auth"       validate:"required"`
	Aws        string `yaml:"aws"`
	Dr         string `yaml:"dr"         validate:"required"`
	Ingress    string `yaml:"ingress"    validate:"required"`
	Logging    string `yaml:"logging"    validate:"required"`
	Monitoring string `yaml:"monitoring" validate:"required"`
	Networking string `yaml:"networking" validate:"required"`
	Tracing    string `yaml:"tracing"`
	Opa        string `yaml:"opa"        validate:"required"`
}

type KFDProvider struct {
	Version   string `yaml:"version"`
	Installer string `yaml:"installer"`
}

type KFDKubernetes struct {
	Eks        KFDProvider `yaml:"eks"        validate:"required"`
	OnPremises KFDProvider `yaml:"onpremises"`
}

type KFDSchemas struct {
	Eks []KFDSchema `yaml:"eks"`
}

type KFDSchema struct {
	APIVersion string `yaml:"apiVersion" validate:"required,api-version"`
	Kind       string `yaml:"kind"       validate:"required,cluster-kind"`
}

type KFDTools struct {
	Common KFDToolsCommon `yaml:"common" validate:"required"`
	Eks    KFDToolsEks    `yaml:"eks"    validate:"required"`
}

type KFDToolsCommon struct {
	Furyagent KFDTool `yaml:"furyagent" validate:"required"`
	Kubectl   KFDTool `yaml:"kubectl"   validate:"required"`
	Kustomize KFDTool `yaml:"kustomize" validate:"required"`
	Terraform KFDTool `yaml:"terraform" validate:"required"`
	OpenTofu  KFDTool `yaml:"opentofu"`
	Yq        KFDTool `yaml:"yq"        validate:"required"`
	Kapp      KFDTool `yaml:"kapp"`
	Helm      KFDTool `yaml:"helm"`
	Helmfile  KFDTool `yaml:"helmfile"`
}

type KFDToolsEks struct {
	Awscli KFDTool `yaml:"awscli" validate:"required"`
}

type KFDTool struct {
	Version   string            `yaml:"version"`
	Checksums map[string]string `yaml:"checksums"`
}
