// Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package config

type Furyctl struct {
	APIVersion string      `yaml:"apiVersion" validate:"required,api-version"`
	Kind       string      `yaml:"kind" validate:"required,cluster-kind"`
	Metadata   FuryctlMeta `yaml:"metadata" validate:"required"`
	Spec       FuryctlSpec `yaml:"spec" validate:"required"`
}

type FuryctlSpec struct {
	DistributionVersion string `yaml:"distributionVersion" validate:"required,permissive-semver"`
}

type FuryctlMeta struct {
	Name string `yaml:"name" validate:"required"`
}

type KFD struct {
	Version        string        `yaml:"version" validate:"required,permissive-semver"`
	Modules        KFDModules    `yaml:"modules" validate:"required"`
	Kubernetes     KFDKubernetes `yaml:"kubernetes" validate:"required"`
	FuryctlSchemas KFDSchemas    `yaml:"furyctlSchemas" validate:"required"`
	Tools          KFDTools      `yaml:"tools" validate:"required"`
}

type KFDModules struct {
	Auth       string `yaml:"auth" validate:"required"`
	Aws        string `yaml:"aws"`
	Dr         string `yaml:"dr" validate:"required"`
	Ingress    string `yaml:"ingress" validate:"required"`
	Logging    string `yaml:"logging" validate:"required"`
	Monitoring string `yaml:"monitoring" validate:"required"`
	Networking string `yaml:"networking" validate:"required"`
	Opa        string `yaml:"opa" validate:"required"`
}

type KFDProvider struct {
	Version   string `yaml:"version" validate:"required"`
	Installer string `yaml:"installer" validate:"required,permissive-semver"`
}

type KFDKubernetes struct {
	Eks KFDProvider `yaml:"eks" validate:"required"`
}

type KFDSchemas struct {
	Eks []KFDSchema `yaml:"eks"`
}

type KFDSchema struct {
	APIVersion string `yaml:"apiVersion" validate:"required,api-version"`
	Kind       string `yaml:"kind" validate:"required,cluster-kind"`
}

type KFDTools struct {
	Common Common `yaml:"common" validate:"required"`
	Eks    Eks    `yaml:"eks" validate:"required"`
}

type Common struct {
	Furyagent Tool `yaml:"furyagent" validate:"required"`
	Kubectl   Tool `yaml:"kubectl" validate:"required"`
	Kustomize Tool `yaml:"kustomize" validate:"required"`
	Terraform Tool `yaml:"terraform" validate:"required"`
}

type Eks struct {
	Awscli Tool `yaml:"awscli" validate:"required"`
}

type Tool struct {
	Version string `yaml:"version" validate:"required,permissive-semver"`
}

func (t Tool) String() string {
	return t.Version
}
