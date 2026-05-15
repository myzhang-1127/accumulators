# Minimal CMake project used only by MrDocs (see ../mrdocs.yml compilation-database).
# Produces a compile_commands.json with a single TU (mrdocs.cpp) so MrDocs does not
# traverse the entire Boost superproject (e.g. Boost.Atomic SSE sources that break
# libclang with GCC 13 intrinsics headers).
#
# BOOST_SRC_DIR must point at the Boost repository root (Antora sets BOOST_SRC_DIR).

cmake_minimum_required(VERSION 3.8...3.20)
project(boost_accumulators_mrdocs_db LANGUAGES CXX)

if(NOT DEFINED BOOST_SRC_DIR OR "${BOOST_SRC_DIR}" STREQUAL "")
    if(DEFINED ENV{BOOST_SRC_DIR} AND NOT "$ENV{BOOST_SRC_DIR}" STREQUAL "")
        file(TO_CMAKE_PATH "$ENV{BOOST_SRC_DIR}" BOOST_SRC_DIR)
    else()
        get_filename_component(BOOST_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../.." ABSOLUTE)
    endif()
endif()
if(NOT EXISTS "${BOOST_SRC_DIR}/CMakeLists.txt")
    message(FATAL_ERROR "BOOST_SRC_DIR must be the Boost repo root; got: ${BOOST_SRC_DIR}")
endif()

# Direct deps match libs/accumulators/CMakeLists.txt plus headers pulled in by
# Boost.Parameter (see libs/parameter/CMakeLists.txt: function, mp11, optional, utility).
set(_acc_deps
    array assert circular_buffer concept_check config core fusion function iterator mpl
    mp11 numeric_conversion numeric_ublas optional parameter preprocessor range
    serialization throw_exception tuple type_traits typeof utility
)

add_library(boost_accumulators_mrdocs_iface INTERFACE)
target_include_directories(boost_accumulators_mrdocs_iface INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/../../include"
)
foreach(_dep ${_acc_deps})
    set(_lib "${_dep}")
    if(_dep STREQUAL "numeric_conversion")
        set(_lib "numeric/conversion")
    elseif(_dep STREQUAL "numeric_ublas")
        set(_lib "numeric/ublas")
    endif()
    set(_inc "${BOOST_SRC_DIR}/libs/${_lib}/include")
    if(NOT EXISTS "${_inc}")
        message(FATAL_ERROR "Expected include dir missing for ${_dep}: ${_inc}")
    endif()
    target_include_directories(boost_accumulators_mrdocs_iface INTERFACE "${_inc}")
endforeach()

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/mrdocs.cpp" "#include <boost/accumulators/accumulators.hpp>\n")
add_executable(boost_accumulators_mrdocs "${CMAKE_CURRENT_BINARY_DIR}/mrdocs.cpp")
target_link_libraries(boost_accumulators_mrdocs PRIVATE boost_accumulators_mrdocs_iface)
target_compile_features(boost_accumulators_mrdocs PRIVATE cxx_std_17)
