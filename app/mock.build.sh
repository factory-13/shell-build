#!/usr/bin/env bash

# -------------------------------------------------------------------------------------------------------------------- #
# Build SRPM & RPM packages.
# -------------------------------------------------------------------------------------------------------------------- #
# @author Kitsune Solar <kitsune.solar@gmail.com>
# @version 1.0.0
# -------------------------------------------------------------------------------------------------------------------- #

ext.mock.get.git(){
    git="$( which git )"

    echo "${git}"
}

ext.mock.dir.build(){
    dir_build="/home/storage/build"

    echo "${dir_build}"
}

ext.mock.dir.factory(){
    dir_build="$( ext.mock.dir.build )"
    dir_factory="${dir_build}/build.factory"

    echo "${dir_factory}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# Build SRPM.
# -------------------------------------------------------------------------------------------------------------------- #

run.mock.build.srpm() {
    config="${1}"
    distr_name="${2}"
    package="${3}"

    git="$( ext.mock.get.git )"
    dir_build="$( ext.mock.dir.build )"
    dir_factory="$( ext.mock.dir.factory )"

    case ${distr_name} in
        centos)
            distr_id="el"
            factory="01"
            ;;
        fedora)
            distr_id="fc"
            factory="02"
            ;;
        *)
            exit 1
            ;;
    esac

    dir_package="${dir_build}/git.${distr_name}/${distr_name}-${package}"

    # Remove current package version.
    if [ -d "${dir_package}" ]; then
        rm -rf "${dir_package}"
    fi

    # Get new package version.
    ${git} clone                                                        \
    https://github.com/factory-${factory}/${distr_name}-${package}.git  \
    "${dir_package}"

    # Copy package sources to build factory.
    if [ -d "${dir_package}/sources" ]; then
        cp -rf "${dir_package}/sources"/* \
        "${dir_factory}/sources/${distr_id}/${package}"
    fi

    # Copy package specs to build factory.
    if [ -d "${dir_package}/specs" ]; then
        cp -rf "${dir_package}/specs"/* \
        "${dir_factory}/specs/${package}"
    fi

    # Run build srpm process.
    file_spec="${dir_factory}/specs/${distr_id}/${package}.spec"
    dir_sources="${dir_factory}/sources/${distr_id}/${package}"
    dir_result="${dir_factory}/srpms/${distr_id}"

    mock -r "${config}"         \
    --spec="${file_spec}"       \
    --sources="${dir_sources}"  \
    --resultdir="${dir_result}" \
    --buildsrpm

    # Copy package srpms to upload directory.
    if [ -f "${dir_result}/${package}"-* ]; then
        cp -rf "${dir_result}/${package}"-* "${HOME}/upload"
    fi
}

# -------------------------------------------------------------------------------------------------------------------- #
# Build RPM.
# -------------------------------------------------------------------------------------------------------------------- #

run.mock.build.rpm() {
    config="${1}"
    distr="${2}"
    package="${3}"

    dir_build="$( ext.mock.dir.build )"
    dir_factory="$( ext.mock.dir.factory )"

    case ${distr_name} in
        centos)
            distr_id="el"
            ;;
        fedora)
            distr_id="fc"
            ;;
        *)
            exit 1
            ;;
    esac

    # Run build rpm process.
    dir_result="${dir_factory}/rpms/${distr_id}"
    file_srpm="${dir_factory}/srpms/${distr_id}/${package}.${distr_id}.src.rpm"

    mock -r "${config}"         \
    --resultdir="${dir_result}" \
    --rebuild "${file_srpm}"
}
