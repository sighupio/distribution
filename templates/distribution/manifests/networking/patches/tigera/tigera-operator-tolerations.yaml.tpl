# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

- op: add
  path: /spec/template/spec/tolerations
  value: 
    - effect: NoExecute
      operator: Exists
    - effect: NoSchedule
      operator: Exists
