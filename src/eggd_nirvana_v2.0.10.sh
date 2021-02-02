#!/bin/bash -x
# eggd_nirvana_2.0.1 0.0.1
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://documentation.dnanexus.com/developer for tutorials on how
# to modify this file.


main() {
    # First we need to install dotnet, which is required to run Nirvana. 
    # This is not available in stock Ubuntu repos so we need to some extra steps to enable this

    # Adapted from:
    # https://docs.microsoft.com/en-us/dotnet/core/install/linux-package-manager-ubuntu-1604
    # https://github.com/dnanexus/dx-toolkit/tree/master/doc/examples/dx-apps/external_apt_repo_example


    # Bypass the APT caching proxy that is built into the execution environment.
    # It's configured to only allow access to the stock Ubuntu repos.
    sudo rm -f /etc/apt/apt.conf.d/99dnanexus

    echo "Setting up dotnet"

    dx download project-Fkb6Gkj433GVVvj73J7x8KbV:file-Fqp7bB8433Gb8YZKPyf9X00k
    mkdir -p "$HOME/dotnet" && tar zxf dotnet-sdk-2.2.207-linux-x64.tar.gz -C "$HOME/dotnet"
    export DOTNET_ROOT=$HOME/dotnet
    export PATH=$PATH:$HOME/dotnet

    # No, I do not want Microsoft looking over my shoulder
    DOTNET_CLI_TELEMETRY_OPTOUT=1

    # dotnet is now installed!
    echo "dotnet installed!"
    
    # Download Nirvana
    echo "Setting up Nirvana"

    # Unpack Nirvana tarball
    tar xzf /Nirvana/Nirvana-2.0.10.tar.gz
    
    # Build Nirvana
    TOP_DIR=$(pwd)
    NIRVANA_ROOT=$TOP_DIR/Nirvana-2.0.10
    NIRVANA_BIN=$NIRVANA_ROOT/bin/Release/netcoreapp2.[01]/Nirvana.dll

    cd $NIRVANA_ROOT
    dotnet build -c Release
    cd $TOP_DIR
    echo "Nirvana built!"


    # Add annotation data
    echo "Building annotation data"

    # Data is stored in 001
    REF_PROJECT=project-Fkb6Gkj433GVVvj73J7x8KbV

    CACHE_FILE=file-Fpg96204gGq4x83kBzp2Yj5G
    REFERENCES_FILE=file-Fp2BK60433GvjKkb706Xf3ZV
    #SUPP_DATABASE_FILE_GRCH37=file-Fpg96PQ4gGq31b9Y28j4qFkj
    #SUPP_DATABASE_FILE_GRCH38=file-G0G4gQ8433GqFK3k1fgJ4GKq

    # Download input vcf
    dx download "$input_vcf"

    echo "Value of input_vcf: '$input_vcf'"
    
    # Determine genome build of input vcf
    # Find reference line in vcf header and extract reference genome filename from that line
    vcf_ref_genome=$(zcat ${input_vcf_name} | grep ^##reference | grep  -o '[^/]*$')
    echo "Reference genome file: $vcf_ref_genome"

    # Find build number in reference filename
    # Contains 37 and does not contain 38 -> build is 37
    if [[ $vcf_ref_genome == *"37"* ]] && [[ $vcf_ref_genome != *"38"* ]]; then
        ref_genome="37"
        SUPP_DATABASE_FILE=file-Fpg96PQ4gGq31b9Y28j4qFkj
    # Contains 38 and does not contain 37 -> build is 38
    elif [[ $vcf_ref_genome == *"38"* ]] && [[ $vcf_ref_genome != *"37"* ]]; then
        ref_genome="38"
        SUPP_DATABASE_FILE=file-G0G4gQ8433GqFK3k1fgJ4GKq
    # Unknown/ambiguous
    else
        echo "Unable to unambiguously determine reference genome (37/38) from input vcf header"
    fi
    
    echo "Input vcf reference build: ${ref_genome}"

    # Download data
    NIRVANA_DATA_DIR=$NIRVANA_ROOT/Data
    mkdir $NIRVANA_DATA_DIR

    echo "Downloading data"
    dx download $REF_PROJECT:$CACHE_FILE -o $NIRVANA_DATA_DIR
    dx download $REF_PROJECT:$REFERENCES_FILE -o $NIRVANA_DATA_DIR
    dx download $REF_PROJECT:$SUPP_DATABASE_FILE -o $NIRVANA_DATA_DIR

    # Unpack it to the expected dirs
    echo "Unpacking data"
    NIRVANA_CACHE_DIR=$NIRVANA_DATA_DIR/Cache
    NIRVANA_REF_DIR=$NIRVANA_DATA_DIR/References
    NIRVANA_SUPP_DIR=$NIRVANA_DATA_DIR/SupplementaryAnnotation

    mkdir -p $NIRVANA_CACHE_DIR $NIRVANA_REF_DIR $NIRVANA_SUPP_DIR

    tar xzf $NIRVANA_DATA_DIR/v26.tar.gz -C $NIRVANA_DATA_DIR
    tar xzf $NIRVANA_DATA_DIR/v5.tar.gz  -C $NIRVANA_DATA_DIR
    tar xzf $NIRVANA_DATA_DIR/v44_GRCh3*.tar.gz -C $NIRVANA_SUPP_DIR
    
    echo "Done building annotation data"


    # Running Nirvana

    # Set reference genome and build links to data resources
    REFERENCE_BUILD=GRCh${ref_genome}
    NIRVANA_CACHE=$NIRVANA_DATA_DIR/Cache/26/$REFERENCE_BUILD/Both  # Numbers here will need to be tweaked if Nirvana version changes
    NIRVANA_SUPP=$NIRVANA_DATA_DIR/SupplementaryAnnotation/$REFERENCE_BUILD
    NIRVANA_REF=$NIRVANA_DATA_DIR/References/5/Homo_sapiens.$REFERENCE_BUILD.Nirvana.dat

    command="dotnet $NIRVANA_BIN --cache $NIRVANA_CACHE --sd $NIRVANA_SUPP --ref $NIRVANA_REF --in $input_vcf_name --out $input_vcf_prefix"
    echo -e $command
    eval $command

    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.

    # The following line(s) use the dx command-line tool to upload your file
    # outputs after you have created them on the local file system.  It assumes
    # that you have used the output field name for the filename for each output,
    # but you can change that behavior to suit your needs.  Run "dx upload -h"
    # to see more options to set metadata.

    output_json=$(dx upload ${input_vcf_prefix}.json.gz --brief)
    
    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output output_json "$output_json" --class=file
}
