#!/usr/bin/env bash

# -------------------------------------------------------------------------------------------------------------------- #
# Build SRPM & RPM packages.
# -------------------------------------------------------------------------------------------------------------------- #
# @author Kitsune Solar <kitsune.solar@gmail.com>
# @version 1.0.0
# -------------------------------------------------------------------------------------------------------------------- #

function ext.mock.build.srpm() {
    local config="${1}"
    local package="${2}"

    mock -r ${config}               \
    --spec=specs/${package}.spec    \
    --sources=sources/${package}    \
    --resultdir=srpms               \
    --buildsrpm
}

function ext.mock.build.rpm() {
    local config="${1}"
    local package="${2}"

    mock -r ${config}   \
    --resultdir=rpms    \
    --rebuild srpms/${package}.src.rpm
}
