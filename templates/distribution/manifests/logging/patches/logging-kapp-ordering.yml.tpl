# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: logging.banzaicloud.io/v1beta1
kind: Logging
metadata:
  name: infra
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/loggings.logging.banzaicloud.io"