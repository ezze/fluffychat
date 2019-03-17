set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(PLUGIN "Qolm")

set(
    SRC
    plugin.cpp
    qolm.cpp
)

set(CMAKE_AUTOMOC ON)

add_library(${PLUGIN} MODULE ${SRC})
set_target_properties(${PLUGIN} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PLUGIN})
qt5_use_modules(${PLUGIN} Qml Quick DBus)

execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

#Find Olm
set(Olm_DIR "${CMAKE_BINARY_DIR}/../olm/${ARCH_TRIPLET}/build")
find_package(Olm)
get_property(OLM_INCLUDES TARGET Olm::Olm PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
get_property(OLM_LIBS TARGET Olm::Olm PROPERTY IMPORTED_LOCATION_RELEASE)
include_directories(${OLM_INCLUDES})
target_link_libraries(${PLUGIN} ${OLM_LIBS})

set(QT_IMPORTS_DIR "/lib/${ARCH_TRIPLET}")

install(TARGETS ${PLUGIN} DESTINATION ${QT_IMPORTS_DIR}/${PLUGIN}/)
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/${PLUGIN}/)
