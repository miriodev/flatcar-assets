#!/usr/bin/env bash
# vim: et ts=2 syn=bash
#
# Aide system extension.
#

RELOAD_SERVICES_ON_MERGE="true"
EXTENSION_VERSION_MATCH_PATTERN='.*(v?[0-9]+\.[0-9]+\.[0-9]+).*'

function list_available_versions() {
  list_github_releases "helm" "helm"
}
# --

function populate_sysext_root() {
  local sysextroot="$1"
  local arch="$2"
  local version="$3"

  local rel_arch="$(arch_transform 'x86-64' 'amd64' "$arch")"
  curl -o helm.tar.gz -fsSL https://get.helm.sh/helm-${version}-linux-${rel_arch}.tar.gz
  tar xfz "helm.tar.gz"
  mkdir -p "${sysextroot}/usr/local/bin/"
  cp -a linux-${rel_arch}/helm "${sysextroot}/usr/local/bin/"
  chmod +x "${sysextroot}/usr/local/bin/helm"


  # Generate 2nd sysupdate config for only patchlevel upgrades.
  local sysupdate="$(get_optional_param "sysupdate" "false" "${@}")"
  if [[ ${sysupdate} == true ]] ; then
    local ver="$(echo "${version}" | sed 's/^\(v[0-9]\+\.[0-9]\+\).*/\1/')"
    _create_sysupdate "${extname}" "${extname}-${ver}.@v-%a.raw" "${extname}" "${extname}" "${extname}-${ver}.conf"
    mv "${extname}-${ver}.conf" "${rundir}"
  fi
}
# --