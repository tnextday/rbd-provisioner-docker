# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang AS build

RUN mkdir -p github.com/kubernetes-incubator \
  && cd github.com/kubernetes-incubator \
  && git clone https://github.com/kubernetes-incubator/external-storage.git \
  && cd /go/src/github.com/kubernetes-incubator/external-storage/ceph/rbd/cmd/rbd-provisioner
  && go build -a -ldflags '-extldflags "-static"' -o /go/bin/rbd-provisioner main.go


FROM centos:7

ENV CEPH_VERSION "luminous"
RUN rpm -Uvh https://download.ceph.com/rpm-$CEPH_VERSION/el7/noarch/ceph-release-1-1.el7.noarch.rpm && \
  yum install -y epel-release && \
  yum install -y --nogpgcheck ceph-common && \
  yum clean all

COPY --from=build /go/bin/rbd-provisioner /usr/local/bin/rbd-provisioner
ENTRYPOINT ["/usr/local/bin/rbd-provisioner"]
