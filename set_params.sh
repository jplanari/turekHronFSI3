#!/usr/bin/env bash

set -e

CONFIG_FILE="simulation_config.ini"

get_ini_value() {
    local section="$1"
    local key="$2"
    awk -F '=' -v section="$section" -v key="$key" '
      BEGIN { in_section=0 }
      # Check for section start
      $0 ~ "\\[" section "\\]" { in_section=1; next }
      # Check for next section
      $0 ~ "^\\[.*\\]" { in_section=0 }
      # If in section, match key ignoring spaces
      in_section {
          gsub(/^[ \t]+|[ \t]+$/, "", $1)   # trim $1 (key)
          gsub(/^[ \t]+|[ \t]+$/, "", $2)   # trim $2 (value)
          if ($1 == key) { print $2; exit }
      }
    ' "$CONFIG_FILE"
}

update_precice_param() {
    local file="$1"
    local tag="$2"
    local value="$3"
    sed -i "s|<$tag value=\"[0-9.eE-]*\" />|<$tag value=\"$value\" />|" "$file"
}

update_dealii_param() {
    local file="$1"
    local param="$2"
    local value="$3"
    sed -i "s|^\([ \t]*set[ \t]\+$param[ \t]*=[ \t]*\).*|\1$value|" "$file"
}

update_openfoam_nu() {
    local file="$1"
    local reynolds="$2"
    local new_value="2.0/$reynolds"

    sed -i "s|^\([ \t]*nu[ \t]\+nu[ \t]\+\[[^]]*\][ \t]*\).*;|\1$new_value;|" "$file"
}

update_openfoam_nu() {
    local file="$1"
    local reynolds="$2"

    local new_value=$(awk -v Re="$reynolds" 'BEGIN { printf("%.6g", 2.0/Re) }')

    sed -i "s|^\([ \t]*nu[ \t]\+nu[ \t]\+\[[^]]*\][ \t]*\).*;|\1$new_value;|" "$file"
}

update_control_dict_param() {
    local file="$1"     # path to controlDict
    local param="$2"    # e.g. endTime or deltaT
    local value="$3"    # new value

    sed -i "s|^\([ \t]*$param[ \t]\+\).*|\1$value;|" "$file"
}

#General (preCICE, Deal.II, OpenFOAM) parameters

TIME_STEP=$(get_ini_value "general" "time_step")
END_TIME=$(get_ini_value "general" "end_time")

#Deal.II parameters

SHEAR_MODULUS=$(get_ini_value "dealII" "shear_modulus")
POISSON_RATIO=$(get_ini_value "dealII" "poisson_ratio")

#OpenFOAM parameters

REFINEMENT_LEVEL=$(get_ini_value "OpenFOAM" "refinement_level")
REYNOLDS_NUMBER=$(get_ini_value "OpenFOAM" "reynolds_number")

PRECICE_XML="precice-config.xml"
CONTROL_DICT="FLUID/system/controlDict"
BLOCK_MESH_DICT="FLUID/system/blockMeshDict"
TRANSPORT_PROPERTIES="FLUID/constant/transportProperties"
DEALII_PARAM_FILE="SOLID/parameters.prm"

echo $PRECICE_XML
echo "END_TIME=$END_TIME, TIME_STEP=$TIME_STEP"

# Update preCICE XML configuration
 
update_precice_param "$PRECICE_XML" "max-time" "$END_TIME"
update_precice_param "$PRECICE_XML" "time-window-size" "$TIME_STEP"

# Update Deal.II parameter file

update_dealii_param "$DEALII_PARAM_FILE" "End time" "$END_TIME"
update_dealii_param "$DEALII_PARAM_FILE" "Time step size" "$TIME_STEP"
update_dealii_param "$DEALII_PARAM_FILE" "Shear modulus" "$SHEAR_MODULUS"
update_dealii_param "$DEALII_PARAM_FILE" "Poisson's ratio" "$POISSON_RATIO"

#Update OpenFOAM dictionaries

echo $REFINEMENT_LEVEL

if [ ${REFINEMENT_LEVEL} -eq 1 ]; then
  cp "FLUID/system/blockMeshDict_base" "$BLOCK_MESH_DICT"
elif [ ${REFINEMENT_LEVEL} -eq 2 ]; then
  cp "FLUID/system/blockMeshDict_refined" "$BLOCK_MESH_DICT"
elif [ ${REFINEMENT_LEVEL} -eq 3 ]; then
  cp "FLUID/system/blockMeshDict_double_refined" "$BLOCK_MESH_DICT"
else
  echo "Error: Unsupported refinement level $REFINEMENT_LEVEL. Supported levels are 1, 2, and 3."
  exit 1
fi

update_openfoam_nu "$TRANSPORT_PROPERTIES" "$REYNOLDS_NUMBER"
update_control_dict_param "$CONTROL_DICT" "endTime" "$END_TIME"
update_control_dict_param "$CONTROL_DICT" "deltaT" "$TIME_STEP"
